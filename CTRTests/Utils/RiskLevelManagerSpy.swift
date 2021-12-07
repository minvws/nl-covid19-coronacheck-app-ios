/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class RiskLevelManagerSpy: RiskLevelManaging {

	required init() {}

	var invokedStateGetter = false
	var invokedStateGetterCount = 0
	var stubbedState: RiskLevel!

	var state: RiskLevel? {
		invokedStateGetter = true
		invokedStateGetterCount += 1
		return stubbedState
	}

	var invokedAppendObserver = false
	var invokedAppendObserverCount = 0
	var stubbedAppendObserverObserverResult: (RiskLevel?, Void)?
	var stubbedAppendObserverResult: RiskLevelManager.ObserverToken!

	func appendObserver(_ observer: @escaping (RiskLevel?) -> Void) -> RiskLevelManager.ObserverToken {
		invokedAppendObserver = true
		invokedAppendObserverCount += 1
		if let result = stubbedAppendObserverObserverResult {
			observer(result.0)
		}
		return stubbedAppendObserverResult
	}

	var invokedRemoveObserver = false
	var invokedRemoveObserverCount = 0
	var invokedRemoveObserverParameters: (token: RiskLevelManager.ObserverToken, Void)?
	var invokedRemoveObserverParametersList = [(token: RiskLevelManager.ObserverToken, Void)]()

	func removeObserver(token: RiskLevelManager.ObserverToken) {
		invokedRemoveObserver = true
		invokedRemoveObserverCount += 1
		invokedRemoveObserverParameters = (token, ())
		invokedRemoveObserverParametersList.append((token, ()))
	}
}
