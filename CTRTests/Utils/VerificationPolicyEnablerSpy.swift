/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

final class VerificationPolicyEnablerSpy: VerificationPolicyEnableable {

	var invokedObservatoryGetter = false
	var invokedObservatoryGetterCount = 0
	var stubbedObservatory: Observatory<[VerificationPolicy]>!

	var observatory: Observatory<[VerificationPolicy]> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

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

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
