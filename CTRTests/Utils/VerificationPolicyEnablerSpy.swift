/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

final class VerificationPolicyEnablerSpy: VerificationPolicyEnablable {

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
}
