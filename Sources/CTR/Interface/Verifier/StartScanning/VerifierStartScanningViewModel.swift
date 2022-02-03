/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie

enum VerifierStartResult {

	case userTappedProceedToScan

	case userTappedProceedToScanInstructions
	
	case userTappedProceedToInstructionsOrRiskSetting
}

class VerifierStartScanningViewModel: Logging {

	// MARK: - Nested Types
	
	indirect enum Mode: Equatable {
		case noLevelSet
		case policy3G
		case policy1G
		case locked(mode: Mode, timeRemaining: TimeInterval, totalDuration: TimeInterval)

		var title: String {
			L.verifierStartTitle()
		}
		
		var header: String? {
			switch self {
				case .locked(_, let timeRemaining, _):
					let timeRemainingString = Mode.timeFormatter.string(from: timeRemaining) ?? "-"
					return L.verifier_home_countdown_title(timeRemainingString, preferredLanguages: nil)
				default:
					return nil
			}
		}
		
		var headerMode: VerifierStartScanningView.HeaderMode? {
			switch self {
				case .noLevelSet, .policy3G:
					return I.scanner.scanStart3GPolicy().map { .image($0) }
				case .policy1G:
					return I.scanner.scanStart1GPolicy().map { .image($0) }
				case .locked(.policy1G, _, _):
					return .animation("switch_to_blue_animation")
				case .locked(.policy3G, _, _):
					return .animation("switch_to_green_animation")
				default:
					return nil
			}
		}
		
		var message: String {
			switch self {
				case let .locked(_, _, totalDuration):
					let minutes = Int((totalDuration / 60).rounded(.up))
					return L.verifier_home_countdown_subtitle(minutes)
				case .policy1G:
					return L.scan_qr_description_1G()
				default:
					return L.verifierStartMessage()
			}
		}
		
		var primaryButtonTitle: String {
			L.verifierStartButtonTitle()
		}
		
		var showInstructionsTitle: String? {
			switch self {
				case .locked: return nil
				default: return L.verifierStartButtonShowinstructions()
			}
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
		
		var allowsShowScanInstructions: Bool {
			switch self {
				case .locked: return false
				default: return true
			}
		}
		
		var riskIndicator: (UIColor, String)? {
			switch self {
				case .policy1G, .locked(.policy1G, _, _):
					return (Theme.colors.primary, L.verifier_start_scan_qr_policy_indication(VerificationPolicy.policy1G.localization))
				case .policy3G, .locked(.policy3G, _, _):
					return (Theme.colors.access, L.verifier_start_scan_qr_policy_indication(VerificationPolicy.policy3G.localization))
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
			formatter.calendar = Calendar(identifier: .gregorian)
			return formatter
		}()
	}
	
	// MARK: - Internal vars
	
	var loggingCategory: String = "VerifierStartViewModel"

	// MARK: - Bindable properties

	@Bindable private(set) var title: String = ""
	@Bindable private(set) var header: String?
	@Bindable private(set) var headerMode: VerifierStartScanningView.HeaderMode?
	@Bindable private(set) var message: String = ""
	@Bindable private(set) var primaryButtonTitle: String = ""
	@Bindable private(set) var showsPrimaryButton: Bool = true
	@Bindable private(set) var showInstructionsTitle: String?
	@Bindable private(set) var showsInstructionsButton: Bool = true
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
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: VerifierCoordinatorDelegate) {

		self.coordinator = coordinator

		// Add a `didSet` callback to the Atomic<Mode>:
		$mode.projectedValue.didSet = { [weak self] atomic in
			guard let self = self else { return }
			
			let newMode: Mode = atomic.wrappedValue
			self.reloadUI(forMode: newMode, hasClockDeviation: Current.clockDeviationManager.hasSignificantDeviation ?? false)
		}
		
		reloadUI(forMode: mode, hasClockDeviation: Current.clockDeviationManager.hasSignificantDeviation ?? false)
		
		// Add an observer for when Clock Deviation is detected/undetected:
		clockDeviationObserverToken = Current.clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			guard let self = self else { return }
			self.reloadUI(forMode: self.mode, hasClockDeviation: hasClockDeviation)
		}
		
		// Pass current states in immediately to configure `self.mode`:
		lockStateDidChange(lockState: Current.scanLockManager.state)
		verificationPolicyDidChange(verificationPolicy: Current.riskLevelManager.state)
		
		// Then observe for changes:
		scanLockObserverToken = Current.scanLockManager.appendObserver { [weak self] in self?.lockStateDidChange(lockState: $0) }
		riskLevelObserverToken = Current.riskLevelManager.appendObserver { [weak self] in self?.verificationPolicyDidChange(verificationPolicy: $0) }
		
		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			
			lockLabelCountdownTimer.fire()
		}
	}
	
	deinit {
		clockDeviationObserverToken.map(Current.clockDeviationManager.removeDeviationChangeObserver)
		lockLabelCountdownTimer.invalidate()
	}
	
	@objc func userTappedMenuButton() {
		
		coordinator?.userWishesToOpenTheMenu()
	}
	
	private func reloadUI(forMode mode: Mode, hasClockDeviation: Bool) {
		title = mode.title
		header = mode.header
		message = mode.message
		primaryButtonTitle = mode.primaryButtonTitle
		showsPrimaryButton = mode.allowsStartScanning
		showInstructionsTitle = mode.showInstructionsTitle
		showsInstructionsButton = mode.allowsShowScanInstructions
		shouldShowClockDeviationWarning = mode.allowsClockDeviationWarning && hasClockDeviation
		headerMode = mode.headerMode
		riskIndicator = mode.riskIndicator
	}
	
	private func lockStateDidChange(lockState: ScanLockManager.State) {
		
		// Update mode with the new lockState:
		self.$mode.projectedValue.mutate { (mode: inout Mode) in
			switch (mode, lockState) {

				// We're already locked, but maybe the `until` time has changed?
				case let (.locked(prelockMode, _, _), .locked(until)):
					let totalDuration = type(of: Current.scanLockManager).configScanLockDuration
					mode = .locked(mode: prelockMode, timeRemaining: until.timeIntervalSinceNow, totalDuration: totalDuration)

				// We're not already locked, but must now lock:
				case (_, .locked(let until)):
					let totalDuration = type(of: Current.scanLockManager).configScanLockDuration
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
	
	private func verificationPolicyDidChange(verificationPolicy: VerificationPolicy?) {
		// Update mode with the new riskLevel:
		self.$mode.projectedValue.mutate { (mode: inout Mode) in
			switch (mode, verificationPolicy) {
				
				// RiskLevel changed, but we're locked. Just update the lock:
				case let (.locked(_, timeRemaining, totalDuration), .policy1G):
					mode = .locked(mode: .policy1G, timeRemaining: timeRemaining, totalDuration: totalDuration)
				case let (.locked(_, timeRemaining, totalDuration), .policy3G):
					mode = .locked(mode: .policy3G, timeRemaining: timeRemaining, totalDuration: totalDuration)
				case let (.locked(_, timeRemaining, totalDuration), .none):
					mode = .locked(mode: .noLevelSet, timeRemaining: timeRemaining, totalDuration: totalDuration)
				
				// Risk Level changed: update mode
				case (_, .policy1G):
					mode = .policy1G
				case (_, .policy3G):
					mode = .policy3G
				case (_, .none):
					mode = .noLevelSet
			}
		}
	}

	/// Update the public keys
	private func updatePublicKeys() {

		// Fetch the public keys from the issuer
		Current.cryptoLibUtility.update(isAppLaunching: false, immediateCallbackIfWithinTTL: nil, completion: nil)
	}
}

// MARK: - Handle User Input:

extension VerifierStartScanningViewModel {
	
	func primaryButtonTapped() {
		guard mode.allowsStartScanning else { return }
		
		if !Current.userSettings.scanInstructionShown ||
			(!Current.userSettings.policyInformationShown && Current.featureFlagManager.is1GPolicyEnabled()) ||
			(Current.riskLevelManager.state == nil && Current.featureFlagManager.areMultipleVerificationPoliciesEnabled()) {
			// Show the scan instructions the first time no matter what link was tapped
			coordinator?.didFinish(.userTappedProceedToInstructionsOrRiskSetting)
		} else {
			if Current.cryptoManager.hasPublicKeys() {
				coordinator?.didFinish(.userTappedProceedToScan)
			} else {
				updatePublicKeys()
				showError = true
			}
		}
	}

	func showInstructionsButtonTapped() {
		
		guard mode.allowsShowScanInstructions || !Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() else { return }
		coordinator?.didFinish(.userTappedProceedToScanInstructions)
	}

	func userDidTapClockDeviationWarningReadMore() {
		coordinator?.userWishesMoreInfoAboutClockDeviation()
	}
}
