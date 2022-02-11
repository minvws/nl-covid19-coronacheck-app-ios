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
	
	func enable(verificationPolicies: [String]) {
		
		var knownPolicies = VerificationPolicy.allCases.filter { verificationPolicies.contains($0.featureFlag) }
		let storedPolicies = Current.userSettings.configVerificationPolicies
		
		if knownPolicies != storedPolicies {
			if storedPolicies.isNotEmpty {
				// Policy is changed, reset scan mode
				Current.wipeScanMode()
				Current.userSettings.policyInformationShown = false
			}
			// Reset navigation
			notifyObservers()
		}
		
		// Set policies that are not set via the scan settings scenes
		switch knownPolicies {
			case [VerificationPolicy.policy1G]:
				Current.riskLevelManager.update(verificationPolicy: .policy1G)
			case [VerificationPolicy.policy3G]:
				Current.riskLevelManager.update(verificationPolicy: nil) // No UI indicator shown
			case []:
				knownPolicies = [VerificationPolicy.policy3G]
				Current.riskLevelManager.update(verificationPolicy: nil) // No UI indicator shown
			default: break
		}
		
		Current.userSettings.configVerificationPolicies = knownPolicies
	}
	
	func wipePersistedData() {

		observers = [:]
		Current.userSettings.configVerificationPolicies = [VerificationPolicy.policy3G]
		Current.riskLevelManager.update(verificationPolicy: nil)
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
}
