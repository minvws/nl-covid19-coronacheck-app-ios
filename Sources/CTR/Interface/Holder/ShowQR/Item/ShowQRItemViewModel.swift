/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Transport
import Shared
import QRGenerator
import Persistence

protocol ShowQRItemViewModelDelegate: AnyObject {
	
	func itemIsNotValid()
	
	func showInfoExpiredQR()
	
	func showInfoHiddenQR()
}

class ShowQRItemViewModel {
	
	// MARK: - Static
	
	static let domesticCorrectionLevel = CorrectionLevel.medium
	static let internationalCorrectionLevel = CorrectionLevel.quartile
	static let screenshotWarningMessageDuration: TimeInterval = 3 * 60
	
	// MARK: - vars
	
	weak private var delegate: ShowQRItemViewModelDelegate?
	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager
	weak private var remoteConfigManager: RemoteConfigManaging? = Current.remoteConfigManager
	
	weak var validityTimer: Timer?
	weak private var screenshotWarningTimer: Timer?
	
	private var greenCard: GreenCard
	private let screenCaptureDetector: ScreenCaptureDetectorProtocol
	private var qrShouldBeHidden: Bool = false
	private let qrShouldInitiallyBeHidden: Bool
	private let disclosusePolicy: DisclosurePolicy?
	private let state: ShowQRState
	
	private var currentQRImage: UIImage? {
		didSet {
			updateQRVisibility()
		}
	}
	private var screenIsBeingCaptured: Bool {
		didSet {
			updateQRVisibility()
		}
	}
	
	private var screenIsBlockedForScreenshotWithSecondsRemaining: Int? {
		didSet {
			updateQRVisibility()
		}
	}
	
	@Bindable private(set) var overlayTitle: String?
	@Bindable private(set) var overlayIcon: UIImage?
	@Bindable private(set) var overlayRevealTitle: String?
	@Bindable private(set) var overlayInfoTitle: String?
	@Bindable private(set) var qrAccessibility: String?
	@Bindable private(set) var visibilityState: ShowQRItemView.VisibilityState = .loading
	
	private var clockDeviationObserverToken: Observatory.ObserverToken?
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - greenCard: a greencard to display
	///   - disclosurePolicy: the policy to disclose the QR with (1G / 3G)
	///   - state: ShowQR State (normal, irrelevant, expired)
	///   - screenCaptureDetector: the screen capture detector
	init(
		delegate: ShowQRItemViewModelDelegate,
		greenCard: GreenCard,
		disclosurePolicy: DisclosurePolicy?,
		state: ShowQRState,
		screenCaptureDetector: ScreenCaptureDetectorProtocol = ScreenCaptureDetector()
	) {
		
		self.delegate = delegate
		self.greenCard = greenCard
		self.disclosusePolicy = disclosurePolicy
		self.screenCaptureDetector = screenCaptureDetector
		self.state = state
		switch self.state {
			case .irrelevant:
				self.qrShouldBeHidden = true
				self.qrShouldInitiallyBeHidden = true
			case .expired:
				self.qrShouldBeHidden = true
				self.qrShouldInitiallyBeHidden = true
			case .regular:
				self.qrShouldBeHidden = false
				self.qrShouldInitiallyBeHidden = false
		}
		
		if greenCard.getType() == GreenCardType.domestic {
			qrAccessibility = L.holderShowqrDomesticQrTitle()
		} else if greenCard.getType() == GreenCardType.eu {
			qrAccessibility = L.holderShowqrEuQrTitle()
		}
		
		screenIsBeingCaptured = screenCaptureDetector.screenIsBeingCaptured
		
		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.screenIsBeingCaptured = isBeingCaptured
		}
		
		screenCaptureDetector.screenshotWasTakenCallback = { [weak self] in
			guard self?.screenIsBlockedForScreenshotWithSecondsRemaining == nil else { return }
			
			let now = Current.now()
			Current.userSettings.lastScreenshotTime = now
			self?.screenshotWasTaken(blockQRUntil: now.addingTimeInterval(ShowQRItemViewModel.screenshotWarningMessageDuration))
		}
		
		if let lastScreenshotTime = Current.userSettings.lastScreenshotTime {
			let expiryDate = lastScreenshotTime.addingTimeInterval(ShowQRItemViewModel.screenshotWarningMessageDuration)
			if expiryDate > Current.now() {
				screenshotWasTaken(blockQRUntil: expiryDate)
			} else {
				Current.userSettings.lastScreenshotTime = nil
			}
		}
		
		clockDeviationObserverToken = Current.clockDeviationManager.observatory.append { [weak self] hasClockDeviation in
			self?.validityTimer?.fire()
		}
		
		updateQRVisibility()
		setupOverlay()
	}
	
	deinit {
		clockDeviationObserverToken.map(Current.clockDeviationManager.observatory.remove)
	}
	
	func setupOverlay() {
		
		switch state {
			case .expired:
				overlayTitle = L.holder_qr_code_expired_overlay_title()
				overlayIcon = I.expired()
				overlayRevealTitle = L.holderShowqrShowqr()
				overlayInfoTitle = L.holder_qr_code_hidden_explanation_button()
			case .irrelevant:
				overlayTitle = L.holderShowqrQrhidden()
				overlayIcon = I.eye()
				overlayRevealTitle = L.holderShowqrShowqr()
				overlayInfoTitle = L.holder_qr_code_hidden_explanation_button()
			case .regular:
				break
		}
	}
	
	func updateQRVisibility() {
		
		if let screenshotBlockTimeRemaining = screenIsBlockedForScreenshotWithSecondsRemaining {
			let mins = screenshotBlockTimeRemaining / 60 % 60
			let secs = screenshotBlockTimeRemaining % 60
			let zeroPaddedSeconds = String(format: "%02d", secs)
			
			let message = L.holderShowqrScreenshotwarningMessage("\(mins):\(zeroPaddedSeconds)")
			
			// Attempt to make a nicer voiceover string:
			let voiceoverTimeRemaining: String
			
			let durationFormatter = DateFormatter.Relative.minutesSeconds
			
			// e.g. "in ten seconds"
			let relativeString = durationFormatter.string(from: Date(), to: Date().addingTimeInterval(TimeInterval(screenshotBlockTimeRemaining)))
			voiceoverTimeRemaining = relativeString.map { L.holderShowqrScreenshotwarningMessage($0) } ?? message
			
			self.visibilityState = .screenshotBlocking(timeRemainingText: message, voiceoverTimeRemainingText: voiceoverTimeRemaining)
			
		} else if screenIsBeingCaptured {
			self.visibilityState = .hiddenForScreenCapture
		} else if let currentQRImage = self.currentQRImage {
			if qrShouldBeHidden {
				self.visibilityState = .overlay(qrImage: currentQRImage)
			} else {
				self.visibilityState = .visible(qrImage: currentQRImage)
			}
		} else {
			self.visibilityState = .loading
		}
	}
	
	private func screenshotWasTaken(blockQRUntil: Date) {
		// Cleanup the old timer
		screenshotWarningTimer?.invalidate()
		screenshotWarningTimer = nil
		
		screenshotWarningTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
			guard let self else { return }
			
			let timeRemaining = blockQRUntil.timeIntervalSince(Current.now())
			
			if timeRemaining <= 1 {
				timer.invalidate()
				self.screenIsBlockedForScreenshotWithSecondsRemaining = nil
			} else {
				self.screenIsBlockedForScreenshotWithSecondsRemaining = Int(timeRemaining)
			}
		}
		screenshotWarningTimer?.fire() // don't wait 1s
	}
	
	/// Check the QR Validity
	@objc func checkQRValidity() {
		
		switch greenCard.getType() {
			case .none:
				setQRNotValid()
			case .domestic:
				guard let data = greenCard.getActiveDomesticCredential()?.data else {
					setQRNotValid()
					return
				}
				DispatchQueue.global(qos: .userInitiated).async {
					
					if let policy = self.disclosusePolicy,
					   let key = Current.secureUserSettings.holderSecretKey,
					   let message = self.cryptoManager?.discloseCredential(data, forPolicy: policy, withKey: key),
					   let image = message.generateQRCode(correctionLevel: ShowQRItemViewModel.domesticCorrectionLevel) {
						DispatchQueue.main.async {
							logVerbose("Update message \(String(decoding: message, as: UTF8.self).prefix(20))")
							self.setQRValid(image: image)
						}
					} else {
						DispatchQueue.main.async {
							self.setQRNotValid()
						}
					}
				}
			case .eu:
				guard let data = greenCard.getLatestInternationalCredential()?.data else {
					setQRNotValid()
					return
				}
				DispatchQueue.global(qos: .userInitiated).async {
					if let image = data.generateQRCode(correctionLevel: ShowQRItemViewModel.internationalCorrectionLevel) {
						DispatchQueue.main.async {
							self.setQRValid(image: image)
						}
					}
				}
		}
	}
	
	private func setQRValid(image: UIImage) {
		
		currentQRImage = image
		startValidityTimer()
	}
	
	private func setQRNotValid() {
		
		currentQRImage = nil
		stopValidityTimer()
		delegate?.itemIsNotValid()
	}
	
	/// Start the validity timer, check every 90 seconds.
	private func startValidityTimer() {
		
		guard validityTimer == nil else {
			return
		}
		
		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(remoteConfigManager?.storedConfiguration.domesticQRRefreshSeconds ?? 60),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}
	
	func stopValidityTimer() {
		
		validityTimer?.invalidate()
		validityTimer = nil
	}
	
	func revealHiddenQR() {
		
		qrShouldBeHidden = false
		updateQRVisibility()
	}
	
	func resetHiddenState() {
		
		qrShouldBeHidden = qrShouldInitiallyBeHidden
	}
	
	func infoButtonTapped() {
		
		switch state {
			case .expired:
				delegate?.showInfoExpiredQR()
			case .irrelevant:
				delegate?.showInfoHiddenQR()
			case .regular:
				break
		}
	}
}
