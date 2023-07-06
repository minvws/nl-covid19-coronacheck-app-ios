/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Models

public class VerificationPolicyManagerSpy: VerificationPolicyManaging {

	public init() {}
	
	public var invokedStateGetter = false
	public var invokedStateGetterCount = 0
	public var stubbedState: VerificationPolicy!

	public var state: VerificationPolicy? {
		invokedStateGetter = true
		invokedStateGetterCount += 1
		return stubbedState
	}

	public var invokedObservatoryGetter = false
	public var invokedObservatoryGetterCount = 0
	public var stubbedObservatory: Observatory<VerificationPolicy?>!

	public var observatory: Observatory<VerificationPolicy?> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	public var invokedUpdate = false
	public var invokedUpdateCount = 0
	public var invokedUpdateParameters: (verificationPolicy: VerificationPolicy?, Void)?
	public var invokedUpdateParametersList = [(verificationPolicy: VerificationPolicy?, Void)]()

	public func update(verificationPolicy: VerificationPolicy?) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (verificationPolicy, ())
		invokedUpdateParametersList.append((verificationPolicy, ()))
	}

	public var invokedWipeScanMode = false
	public var invokedWipeScanModeCount = 0

	public func wipeScanMode() {
		invokedWipeScanMode = true
		invokedWipeScanModeCount += 1
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
