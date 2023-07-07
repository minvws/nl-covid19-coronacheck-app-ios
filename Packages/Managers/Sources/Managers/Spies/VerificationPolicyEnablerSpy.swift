/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Models

final public class VerificationPolicyEnablerSpy: VerificationPolicyEnableable {

	public init() {}
	
	public var invokedObservatoryGetter = false
	public var invokedObservatoryGetterCount = 0
	public var stubbedObservatory: Observatory<[VerificationPolicy]>!

	public var observatory: Observatory<[VerificationPolicy]> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
