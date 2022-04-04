/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol VerificationPolicyEnableable: AnyObject {
	var observatory: Observatory<[VerificationPolicy]> { get }
	
	func enable(verificationPolicies: [String])
	func wipePersistedData()
}

final class VerificationPolicyEnabler: VerificationPolicyEnableable {
	
	// Mechanism for registering for external state change notifications:
	let observatory: Observatory<[VerificationPolicy]>
	private let notifyObservers: ([VerificationPolicy]) -> Void
	
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
		(self.observatory, self.notifyObservers) = Observatory<[VerificationPolicy]>.create()
		
		guard AppFlavor.flavor == .verifier else { return }
		
		enable(verificationPolicies: remoteConfigManager.storedConfiguration.verificationPolicies ?? [])
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverToken.map(remoteConfigManager.observatoryForUpdates.remove)
	}
	
	private func configureRemoteConfigManager() {
		
		remoteConfigManagerObserverToken = remoteConfigManager.observatoryForUpdates.append { [weak self] remoteConfiguration, _, _ in
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
			notifyObservers(knownPolicies)
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

		observatory.removeAll()
		userSettings.configVerificationPolicies = [VerificationPolicy.policy3G]
		verificationPolicyManager.update(verificationPolicy: nil)
	}
	
	/// Reset verifier scan mode, including risk setting, scan lock and scan log
	private func wipeScanMode() {
		// Scan lock and risk level observers are not wiped
		// in case this method is called after setting the observers in VerifierStartScanningViewModel
		verificationPolicyManager.wipeScanMode()
		scanLockManager.wipeScanMode()
		scanLogManager.wipePersistedData()
	}
}
