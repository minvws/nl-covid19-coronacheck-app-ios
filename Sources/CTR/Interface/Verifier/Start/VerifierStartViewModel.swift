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
		case locked(mode: Mode, timeRemaining: TimeInterval, totalDuration: TimeInterval)

		var title: String {
			L.verifierStartTitle()
		}
		
		var header: String {
			switch self {
				case .locked(_, let timeRemaining, _):
					let timeRemainingString = Mode.timeFormatter.string(from: timeRemaining) ?? "-"
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
			switch self {
				case let .locked(_, _, totalDuration):
					let minutes = Int((totalDuration / 60).rounded(.up))
					return L.verifier_home_countdown_subtitle(minutes)

				default:
					return L.verifierStartMessage()
			}
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
				case .highRisk, .locked(.highRisk, _, _):
					return (Theme.colors.primary, L.verifier_start_scan_qr_policy_indication_2g())
				case .lowRisk, .locked(.lowRisk, _, _):
					return (Theme.colors.access, L.verifier_start_scan_qr_policy_indication_3g())
				default:
					return nil
			}
		}
		
		private static var timeFormatter: DateComponentsFormatter = {
			let formatter = DateComponentsFormatter()
			formatter.allowedUnits = [.minute, .second]
			formatter.collapsesLargestUnit = false
			formatter.unitsStyle = .positional
			formatter.zeroFormattingBehavior = .pad
			return formatter
		}()
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

	// MARK: - State
	
	@Atomic<Mode>
	private var mode = .noLevelSet // swiftlint:disable:this let_var_whitespace
	
	private lazy var lockLabelCountdownTimer: Timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
		guard let self = self,
			  case let .locked(mode, timeRemaining, totalDuration) = self.mode,
			  timeRemaining > 0
		else { return }
		self.mode = .locked(mode: mode, timeRemaining: timeRemaining - 1, totalDuration: totalDuration)
	}

	// MARK: - Observer tokens
	
	private var clockDeviationObserverToken: ClockDeviationManager.ObserverToken?
	private var scanLockObserverToken: ScanLockManager.ObserverToken?
	private var riskLevelObserverToken: RiskLevelManager.ObserverToken?

	// MARK: - Dependencies
	
	private weak var coordinator: VerifierCoordinatorDelegate?
	private weak var cryptoManager: CryptoManaging? = Services.cryptoManager
	private weak var cryptoLibUtility: CryptoLibUtilityProtocol? = Services.cryptoLibUtility
	private var userSettings: UserSettingsProtocol
	private let clockDeviationManager: ClockDeviationManaging = Services.clockDeviationManager
	private let scanLockProvider: ScanLockManaging
	private let riskLevelProvider: RiskLevelManaging
	private weak var scanLogManager: ScanLogManaging? = Services.scanLogManager
	private weak var remoteConfigurationManager: RemoteConfigManaging? = Services.remoteConfigManager
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userSettings: the user managed settings
	init(
		coordinator: VerifierCoordinatorDelegate,
		scanLockProvider: ScanLockManaging,
		riskLevelProvider: RiskLevelManaging,
		userSettings: UserSettingsProtocol = UserSettings()
	) {

		self.coordinator = coordinator
		self.scanLockProvider = scanLockProvider
		self.riskLevelProvider = riskLevelProvider
		self.userSettings = userSettings

		// Add a `didSet` callback to the Atomic<Mode>:
		$mode.projectedValue.didSet = { [weak self] atomic in
			guard let self = self else { return }
			
			let newMode: Mode = atomic.wrappedValue
			self.reloadUI(forMode: newMode, hasClockDeviation: self.clockDeviationManager.hasSignificantDeviation ?? false)
		}
		
		reloadUI(forMode: mode, hasClockDeviation: clockDeviationManager.hasSignificantDeviation ?? false)
		
		// Add an observer for when Clock Deviation is detected/undetected:
		clockDeviationObserverToken = clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			guard let self = self else { return }
			self.reloadUI(forMode: self.mode, hasClockDeviation: hasClockDeviation)
		}

		// Pass current scanLockProvider state in immediately to configure `self.mode`
		lockStateDidChange(lockState: scanLockProvider.state)
		
		// Then observer for changes:
		scanLockObserverToken = scanLockProvider.appendObserver { [weak self] lockState in
			self?.lockStateDidChange(lockState: lockState)
		}
		
		riskLevelObserverToken = riskLevelProvider.appendObserver { [weak self] riskLevel in
			self?.riskLevelDidChange(riskLevel: riskLevel)
		}

		lockLabelCountdownTimer.fire()

		cleanupScanLog()
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
	
	private func lockStateDidChange(lockState: ScanLockManager.State) {
		
		// Update mode with the new lockState:
		self.$mode.projectedValue.mutate { (mode: inout Mode) in
			switch (mode, lockState) {

				// We're already locked, but maybe the `until` time has changed?
				case let (.locked(prelockMode, _, _), .locked(until)):
					let totalDuration = type(of: scanLockProvider).configScanLockDuration
					mode = .locked(mode: prelockMode, timeRemaining: until.timeIntervalSinceNow, totalDuration: totalDuration)

				// We're not already locked, but must now lock:
				case (_, .locked(let until)):
					let totalDuration = type(of: scanLockProvider).configScanLockDuration
					mode = .locked(mode: mode, timeRemaining: until.timeIntervalSinceNow, totalDuration: totalDuration)

				// We're locked, but must unlock:
				case let (.locked(prelockMode, _, _), .unlocked):
					mode = prelockMode

				// We're not locked and so unlocking does nothing:
				case (_, .unlocked):
					break
			}
		}
	}
	
	private func riskLevelDidChange(riskLevel: RiskLevel?) {
		// Update mode with the new riskLevel:
		self.$mode.projectedValue.mutate { (mode: inout Mode) in
			switch (mode, riskLevel) {
				
				// RiskLevel changed, but we're locked. Just update the lock:
				case let (.locked(_, timeRemaining, totalDuration), .high):
					mode = .locked(mode: .highRisk, timeRemaining: timeRemaining, totalDuration: totalDuration)
				case let (.locked(_, timeRemaining, totalDuration), .low):
					mode = .locked(mode: .lowRisk, timeRemaining: timeRemaining, totalDuration: totalDuration)
				case let (.locked(_, timeRemaining, totalDuration), .none):
					mode = .locked(mode: .noLevelSet, timeRemaining: timeRemaining, totalDuration: totalDuration)
				
				// Risk Level changed: update mode
				case (_, .high):
					mode = .highRisk
				case (_, .low):
					mode = .lowRisk
				case (_, .none):
					mode = .noLevelSet
			}
		}
	}

	/// Update the public keys
	private func updatePublicKeys() {

		// Fetch the public keys from the issuer
		cryptoLibUtility?.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: nil, completion: nil)
	}

	private func cleanupScanLog() {

		scanLogManager?.deleteExpiredScanLogEntries(seconds: remoteConfigurationManager?.storedConfiguration.scanLogStorageSeconds ?? 3600)
	}
}

// MARK: - Handle User Input:

extension VerifierStartViewModel {
	
	func primaryButtonTapped() {
		guard mode.allowsStartScanning else { return }

		if userSettings.scanInstructionShown, riskLevelProvider.state != nil {
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
}
