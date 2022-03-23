/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol VerificationPolicyEnablable: AnyObject {
	
	typealias ObserverToken = UUID
	
	func enable(verificationPolicies: [String])
	func appendPolicyChangedObserver(_ observer: @escaping () -> Void) -> ObserverToken
	func removeObserver(token: ObserverToken)
	func wipePersistedData()
}

final class VerificationPolicyEnabler: VerificationPolicyEnablable {
	
	private var observers = [ObserverToken: () -> Void]()
	private let remoteConfigManager: RemoteConfigManaging
	private let userSettings: UserSettingsProtocol
	private var remoteConfigManagerObserverToken: UUID?
	private let verificationPolicyManager: VerificationPolicyManaging
	private let scanLockManager: ScanLockManaging
	private let scanLogManager: ScanLogManaging
	
	/// Initiializer
	init(
		remoteConfigManager: RemoteConfigManaging,
		userSettings: UserSettingsProtocol,
		verificationPolicyManager: VerificationPolicyManaging,
		scanLockManager: ScanLockManaging,
		scanLogManager: ScanLogManaging
	) {
		self.remoteConfigManager = remoteConfigManager
		self.userSettings = userSettings
		self.verificationPolicyManager = verificationPolicyManager
		self.scanLockManager = scanLockManager
		self.scanLogManager = scanLogManager
		
		guard AppFlavor.flavor == .verifier else { return }
		
		enable(verificationPolicies: remoteConfigManager.storedConfiguration.verificationPolicies ?? [])
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverToken.map(remoteConfigManager.removeObserver)
	}
	
	private func configureRemoteConfigManager() {
		
		remoteConfigManagerObserverToken = remoteConfigManager.appendUpdateObserver { [weak self] remoteConfiguration, _, _ in
			guard let policies = remoteConfiguration.verificationPolicies else {
				// No feature flag available, enable default policy
				self?.enable(verificationPolicies: [])
				return
			}
			self?.enable(verificationPolicies: policies)
		}
	}
		
	func enable(verificationPolicies: [String]) {
		
		var knownPolicies = VerificationPolicy.allCases.filter { verificationPolicies.contains($0.featureFlag) }
		let storedPolicies = userSettings.configVerificationPolicies
		
		if knownPolicies != storedPolicies {
			if storedPolicies.isNotEmpty {
				// Policy is changed, reset scan mode
				wipeScanMode()
				userSettings.policyInformationShown = false
			}
			// Reset navigation
			notifyObservers()
		}
		
		// Set policies that are not set via the scan settings scenes
		switch knownPolicies {
			case [VerificationPolicy.policy1G]:
				verificationPolicyManager.update(verificationPolicy: .policy1G)
			case [VerificationPolicy.policy3G]:
				verificationPolicyManager.update(verificationPolicy: nil) // No UI indicator shown
			case []:
				knownPolicies = [VerificationPolicy.policy3G]
				verificationPolicyManager.update(verificationPolicy: nil) // No UI indicator shown
			default: break
		}
		
		userSettings.configVerificationPolicies = knownPolicies
	}
	
	func wipePersistedData() {

		observers = [:]
		userSettings.configVerificationPolicies = [VerificationPolicy.policy3G]
		verificationPolicyManager.update(verificationPolicy: nil)
	}
	
	// MARK: - Observer notifications
	
	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func appendPolicyChangedObserver(_ observer: @escaping () -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		observers[newToken] = observer
		return newToken
	}

	func removeObserver(token: ObserverToken) {
		observers[token] = nil
	}
}

private extension VerificationPolicyEnabler {
	
	func notifyObservers() {
		observers.values.forEach { callback in
			callback()
		}
	}
	
	/// Reset verifier scan mode, including risk setting, scan lock and scan log
	func wipeScanMode() {
		// Scan lock and risk level observers are not wiped
		// in case this method is called after setting the observers in VerifierStartScanningViewModel
		verificationPolicyManager.wipeScanMode()
		scanLockManager.wipeScanMode()
		scanLogManager.wipePersistedData()
	}
}
