/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ShowQRItemViewModelDelegate: AnyObject {

	func itemIsNotValid()
}

class ShowQRItemViewModel: Logging {

	// MARK: - Static
	
	static let domesticCorrectionLevel = "M"
	static let internationalCorrectionLevel = "Q"
	static let screenshotWarningMessageDuration: TimeInterval = 3 * 60

	// MARK: - vars

	weak private var delegate: ShowQRItemViewModelDelegate?
	weak private var cryptoManager: CryptoManaging? = Services.cryptoManager
	weak private var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager

	weak var validityTimer: Timer?
	weak private var screenshotWarningTimer: Timer?

	private var previousBrightness: CGFloat?
	private var greenCard: GreenCard
	private let screenCaptureDetector: ScreenCaptureDetectorProtocol

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

	@Bindable private(set) var title: String?
    
    @Bindable private(set) var qrAccessibility: String?

	@Bindable private(set) var visibilityState: ShowQRItemView.VisibilityState = .loading

	private let userSettings: UserSettingsProtocol
	private let now: () -> Date
	private var clockDeviationObserverToken: ClockDeviationManager.ObserverToken?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - greenCard: a greencard to display
	///   - screenCaptureDetector: the screen capture detector
	init(
		delegate: ShowQRItemViewModelDelegate,
		greenCard: GreenCard,
		screenCaptureDetector: ScreenCaptureDetectorProtocol = ScreenCaptureDetector(),
		userSettings: UserSettingsProtocol = UserSettings(),
		now: @escaping () -> Date = Date.init
	) {

		self.delegate = delegate
		self.greenCard = greenCard
		self.screenCaptureDetector = screenCaptureDetector
		self.userSettings = userSettings
		self.now = now

		if greenCard.type == GreenCardType.domestic.rawValue {
			qrAccessibility = L.holderShowqrDomesticQrTitle()
		} else if greenCard.type == GreenCardType.eu.rawValue {
            qrAccessibility = L.holderShowqrEuQrTitle()
		}

		screenIsBeingCaptured = screenCaptureDetector.screenIsBeingCaptured

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.screenIsBeingCaptured = isBeingCaptured
		}

		screenCaptureDetector.screenshotWasTakenCallback = { [weak self] in
			guard self?.screenIsBlockedForScreenshotWithSecondsRemaining == nil else { return }
			userSettings.lastScreenshotTime = now()
			self?.screenshotWasTaken(blockQRUntil: now().addingTimeInterval(ShowQRItemViewModel.screenshotWarningMessageDuration))
		}

		if let lastScreenshotTime = userSettings.lastScreenshotTime {
			let expiryDate = lastScreenshotTime.addingTimeInterval(ShowQRItemViewModel.screenshotWarningMessageDuration)
			if expiryDate > now() {
				screenshotWasTaken(blockQRUntil: expiryDate)
			} else {
				userSettings.lastScreenshotTime = nil
			}
		}

		clockDeviationObserverToken = Services.clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			self?.validityTimer?.fire()
		}

		updateQRVisibility()
	}

	deinit {
		clockDeviationObserverToken.map(Services.clockDeviationManager.removeDeviationChangeObserver)
	}

	func updateQRVisibility() {

		if let screenshotBlockTimeRemaining = screenIsBlockedForScreenshotWithSecondsRemaining {
			let mins = screenshotBlockTimeRemaining / 60 % 60
			let secs = screenshotBlockTimeRemaining % 60
			let zeroPaddedSeconds = String(format: "%02d", secs)

			let message = L.holderShowqrScreenshotwarningMessage("\(mins):\(zeroPaddedSeconds)")

			// Attempt to make a nicer voiceover string:
			let voiceoverTimeRemaining: String

			let durationFormatter = DateComponentsFormatter()
			durationFormatter.unitsStyle = . full
			durationFormatter.maximumUnitCount = 2
			durationFormatter.allowedUnits = [.minute, .second]

			// e.g. "in ten seconds"
			let relativeString = durationFormatter.string(from: Date(), to: Date().addingTimeInterval(TimeInterval(screenshotBlockTimeRemaining)))
			voiceoverTimeRemaining = relativeString.map { L.holderShowqrScreenshotwarningMessage($0) } ?? message

			self.visibilityState = .screenshotBlocking(timeRemainingText: message, voiceoverTimeRemainingText: voiceoverTimeRemaining)

		} else if screenIsBeingCaptured {
			self.visibilityState = .hiddenForScreenCapture
		} else if let currentQRImage = self.currentQRImage {
			self.visibilityState = .visible(qrImage: currentQRImage)
		} else {
			self.visibilityState = .loading
		}
	}

	private func screenshotWasTaken(blockQRUntil: Date) {
		// Cleanup the old timer
		screenshotWarningTimer?.invalidate()
		screenshotWarningTimer = nil

		screenshotWarningTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
			guard let self = self else { return }

			let timeRemaining = blockQRUntil.timeIntervalSince(self.now())

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

		guard let credential = self.greenCard.getActiveCredential(),
			  let data = credential.data,
			  let expirationTime = credential.expirationTime, expirationTime > Date() else {
			setQRNotValid()
			return
		}

		if greenCard.type == GreenCardType.domestic.rawValue {
			DispatchQueue.global(qos: .userInitiated).async {
				if let message = self.cryptoManager?.generateQRmessage(data),
				   let image = message.generateQRCode(correctionLevel: ShowQRItemViewModel.domesticCorrectionLevel) {
					DispatchQueue.main.async {
						self.setQRValid(image: image)
					}
				} else {
					DispatchQueue.main.async {
						self.setQRNotValid()
					}
				}
			}
		} else {
			DispatchQueue.global(qos: .userInitiated).async {
				// International
				if let image = data.generateQRCode(correctionLevel: ShowQRItemViewModel.internationalCorrectionLevel) {
					DispatchQueue.main.async {
						self.setQRValid(image: image)
					}
				}
			}
			setTitleForVaccinationDosage(data)
		}
	}

	private func setTitleForVaccinationDosage(_ data: Data) {

		if let euCredentialAttributes = self.cryptoManager?.readEuCredentials(data),
		   let euVaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first,
		   let doseNumber = euVaccination.doseNumber,
		   let totalDose = euVaccination.totalDose {
			title = L.holderShowqrQrEuVaccinecertificatedoses("\(doseNumber)", "\(totalDose)")
		}
	}

	private func setQRValid(image: UIImage) {

		logDebug("Credential is valid")
		currentQRImage = image
		startValidityTimer()
	}

	private func setQRNotValid() {

		logWarning("Credential is not valid")
		currentQRImage = nil
		stopValidityTimer()
		delegate?.itemIsNotValid()
	}

	/// Adjust the brightness
	/// - Parameter reset: True if we reset to previous value
	func setBrightness(reset: Bool = false) {

		let currentBrightness = UIScreen.main.brightness
		if currentBrightness < 1 {
			previousBrightness = currentBrightness
		}

		UIScreen.main.brightness = reset ? previousBrightness ?? 1 : 1
	}

	/// Start the validity timer, check every 90 seconds.
	private func startValidityTimer() {

		guard validityTimer == nil else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(remoteConfigManager?.getConfiguration().domesticQRRefreshSeconds ?? 60),
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
}
