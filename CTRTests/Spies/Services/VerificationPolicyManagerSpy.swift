/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Shared
@testable import CTR
@testable import Models

class VerificationPolicyManagerSpy: VerificationPolicyManaging {

	var invokedStateGetter = false
	var invokedStateGetterCount = 0
	var stubbedState: VerificationPolicy!

	var state: VerificationPolicy? {
		invokedStateGetter = true
		invokedStateGetterCount += 1
		return stubbedState
	}

	var invokedObservatoryGetter = false
	var invokedObservatoryGetterCount = 0
	var stubbedObservatory: Observatory<VerificationPolicy?>!

	var observatory: Observatory<VerificationPolicy?> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	var invokedUpdate = false
	var invokedUpdateCount = 0
	var invokedUpdateParameters: (verificationPolicy: VerificationPolicy?, Void)?
	var invokedUpdateParametersList = [(verificationPolicy: VerificationPolicy?, Void)]()

	func update(verificationPolicy: VerificationPolicy?) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (verificationPolicy, ())
		invokedUpdateParametersList.append((verificationPolicy, ()))
	}

	var invokedWipeScanMode = false
	var invokedWipeScanModeCount = 0

	func wipeScanMode() {
		invokedWipeScanMode = true
		invokedWipeScanModeCount += 1
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
