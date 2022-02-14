/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class DisclosurePolicyManagingSpy: DisclosurePolicyManaging {

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
}
