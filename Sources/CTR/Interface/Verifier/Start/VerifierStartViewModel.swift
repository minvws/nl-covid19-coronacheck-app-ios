/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum VerifierStartResult {

	case userTappedProceedToScan

	case userTappedProceedToScanInstructions
}

class VerifierStartViewModel: Logging {

	// MARK: - Nested Types
	
	indirect enum Mode: Equatable {
		case noLevelSet
		case lowRisk
		case highRisk
		case locked(mode: Mode, timeRemaining: TimeInterval)

		var title: String {
			L.verifierStartTitle()
		}
		
		var header: String {
			switch self {
				case .locked(_, let timeRemaining):
					let formatter = timeRemaining > 59 ? Mode.minuteFormatter : Mode.secondFormatter
					let timeRemainingString = formatter.string(from: timeRemaining) ?? "-"
					return L.verifier_home_countdown_title(timeRemainingString, preferredLanguages: nil)
					
				default:
					return L.verifierStartHeader()
			}
		}
		
		var largeImage: UIImage? {
			switch self {
				case .noLevelSet, .lowRisk:
					return I.scanStartLowRisk()
				case .highRisk:
					return I.scanStartHighRisk()
				case .locked:
					return I.scanStartLocked()
			}
		}
		
		var message: String {
			L.verifierStartMessage()
		}
		
		var primaryButtonTitle: String {
			L.verifierStartButtonTitle()
		}
		
		var showInstructionsTitle: String {
			L.verifierStartButtonShowinstructions()
		}
		
		var allowsClockDeviationWarning: Bool {
			switch self {
				case .locked: return false
				default: return true
			}
		}
		
		var allowsStartScanning: Bool {
			switch self {
				case .locked: return false
				default: return true
			}
		}
		
		var riskIndicator: (UIColor, String)? {
			switch self {
				case .highRisk, .locked(.highRisk, _):
					return (Theme.colors.primary, L.verifier_start_scan_qr_policy_indication_2g())
				case .lowRisk, .locked(.lowRisk, _):
					return (Theme.colors.access, L.verifier_start_scan_qr_policy_indication_3g())
				default:
					return nil
			}
		}
		
		private static var minuteFormatter: DateComponentsFormatter = {
			let formatter = DateComponentsFormatter()
			formatter.unitsStyle = .full
			formatter.allowedUnits = [.minute]
			return formatter
		}()
		
		private static var secondFormatter: DateComponentsFormatter = {
			let formatter = DateComponentsFormatter()
			formatter.unitsStyle = .full
			formatter.allowedUnits = [.second]
			return formatter
		}()
	}
	
	// MARK: - Static
	
	/// Query the Remote Config Manager for the scan lock duration.
	private static var configScanLockDuration: TimeInterval {
		TimeInterval(Services.remoteConfigManager.storedConfiguration.scanLockSeconds ?? 300)
	}
	
	// MARK: - Internal vars
	
	var loggingCategory: String = "VerifierStartViewModel"

	// MARK: - Bindable properties

	@Bindable private(set) var title: String = ""
	@Bindable private(set) var header: String = ""
	@Bindable private(set) var largeImage: UIImage?
	@Bindable private(set) var message: String = ""
	@Bindable private(set) var primaryButtonTitle: String = ""
	@Bindable private(set) var showsPrimaryButton: Bool = true
	@Bindable private(set) var showInstructionsTitle: String = ""
	@Bindable private(set) var showError: Bool = false
	@Bindable private(set) var shouldShowClockDeviationWarning = false
	@Bindable private(set) var riskIndicator: (UIColor, String)?

	// MARK: - Dependencies
	
	private weak var coordinator: VerifierCoordinatorDelegate?
	private weak var cryptoManager: CryptoManaging? = Services.cryptoManager
	private weak var cryptoLibUtility: CryptoLibUtilityProtocol? = Services.cryptoLibUtility
	private var userSettings: UserSettingsProtocol
	private let clockDeviationManager: ClockDeviationManaging = Services.clockDeviationManager

	// MARK: - State
	
	private var mode: Mode = .noLevelSet {
		didSet {
			reloadUI(forMode: mode, hasClockDeviation: clockDeviationManager.hasSignificantDeviation ?? false)
		}
	}
	
	private var clockDeviationObserverToken: ClockDeviationManager.ObserverToken?
	
	private lazy var lockLabelCountdownTimer: Timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
		guard let self = self else { return }
		
		// Simplistic implementation for now. Once we have the locking mechanism integrated,
		// this can be revisited.
		guard case let .locked(mode, timeRemaining) = self.mode else { return }
		
		self.mode = {
			if timeRemaining <= 1 {
				return mode
			} else {
				return .locked(mode: mode, timeRemaining: timeRemaining - 1)
			}
		}()
	}
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userSettings: the user managed settings
	init(
		coordinator: VerifierCoordinatorDelegate,
		userSettings: UserSettingsProtocol = UserSettings()
	) {

		self.coordinator = coordinator
		self.userSettings = userSettings

		reloadUI(forMode: mode, hasClockDeviation: clockDeviationManager.hasSignificantDeviation ?? false)
		
		clockDeviationObserverToken = clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			guard let self = self else { return }
			self.reloadUI(forMode: self.mode, hasClockDeviation: hasClockDeviation)
		}
		
		lockLabelCountdownTimer.fire()
	}
	
	deinit {
		clockDeviationObserverToken.map(clockDeviationManager.removeDeviationChangeObserver)
		
		lockLabelCountdownTimer.invalidate()
	}
	
	private func reloadUI(forMode mode: Mode, hasClockDeviation: Bool) {
		title = mode.title
		header = mode.header
		message = mode.message
		primaryButtonTitle = mode.primaryButtonTitle
		showsPrimaryButton = mode.allowsStartScanning
		showInstructionsTitle = mode.showInstructionsTitle
		shouldShowClockDeviationWarning = mode.allowsClockDeviationWarning && hasClockDeviation
		largeImage = mode.largeImage
		riskIndicator = mode.riskIndicator
	}

	func primaryButtonTapped() {
		guard mode.allowsStartScanning else { return }

		if userSettings.scanInstructionShown {
			if let crypto = cryptoManager, crypto.hasPublicKeys() {
				coordinator?.didFinish(.userTappedProceedToScan)
			} else {
				updatePublicKeys()
				showError = true
			}
		} else {
			// Show the scan instructions the first time no matter what link was tapped
			coordinator?.didFinish(.userTappedProceedToScanInstructions)
		}
	}

	func showInstructionsButtonTapped() {
		coordinator?.didFinish(.userTappedProceedToScanInstructions)
	}

	func userDidTapClockDeviationWarningReadMore() {
		coordinator?.userWishesMoreInfoAboutClockDeviation()
	}

	/// Update the public keys
	private func updatePublicKeys() {

		// Fetch the public keys from the issuer
		cryptoLibUtility?.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: nil, completion: nil)
	}
}
