/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

final class VerificationPolicyEnablerSpy: VerificationPolicyEnableable {

	var invokedEnable = false
	var invokedEnableCount = 0
	var invokedEnableParameters: (verificationPolicies: [String], Void)?
	var invokedEnableParametersList = [(verificationPolicies: [String], Void)]()

	func enable(verificationPolicies: [String]) {
		invokedEnable = true
		invokedEnableCount += 1
		invokedEnableParameters = (verificationPolicies, ())
		invokedEnableParametersList.append((verificationPolicies, ()))
	}

	var invokedConfigureDefaultPolicy = false
	var invokedConfigureDefaultPolicyCount = 0

	func configureDefaultPolicy() {
		invokedConfigureDefaultPolicy = true
		invokedConfigureDefaultPolicyCount += 1
	}

	var invokedAppendPolicyChangedObserver = false
	var invokedAppendPolicyChangedObserverCount = 0
	var shouldInvokeAppendPolicyChangedObserverObserver = false
	var stubbedAppendPolicyChangedObserverResult: ObserverToken!

	func appendPolicyChangedObserver(_ observer: @escaping () -> Void) -> ObserverToken {
		invokedAppendPolicyChangedObserver = true
		invokedAppendPolicyChangedObserverCount += 1
		if shouldInvokeAppendPolicyChangedObserverObserver {
			observer()
		}
		return stubbedAppendPolicyChangedObserverResult
	}

	var invokedRemoveObserver = false
	var invokedRemoveObserverCount = 0
	var invokedRemoveObserverParameters: (token: ObserverToken, Void)?
	var invokedRemoveObserverParametersList = [(token: ObserverToken, Void)]()

	func removeObserver(token: ObserverToken) {
		invokedRemoveObserver = true
		invokedRemoveObserverCount += 1
		invokedRemoveObserverParameters = (token, ())
		invokedRemoveObserverParametersList.append((token, ()))
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
