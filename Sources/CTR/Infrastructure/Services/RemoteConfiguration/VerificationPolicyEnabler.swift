/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol VerificationPolicyEnablable: AnyObject {
	
	func enable(verificationPolicies: [String])
}

final class VerificationPolicyEnabler {
	
	func enable(verificationPolicies: [String]) {
		
		let knownPolicies = VerificationPolicy.allCases.compactMap {
			return verificationPolicies.contains($0.featureFlag) ? $0 : nil
		}
		guard knownPolicies.isNotEmpty() else {
			
			// Configure default policy
			Current.userSettings.configVerificationPolicies = [VerificationPolicy.policy3G]
			return
		}
		
		let storedPolicies = Current.userSettings.configVerificationPolicies
		if knownPolicies != storedPolicies {
			if storedPolicies.isNotEmpty() {
				// Policy is changed, reset scan mode
				Current.wipeScanMode()
			}
			Current.userSettings.configVerificationPolicies = knownPolicies
		}
	}
}
