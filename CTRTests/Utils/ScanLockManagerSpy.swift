/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class ScanLockManagerSpy: ScanLockManaging {

	required init() {}
	
	var invokedStateGetter = false
	var invokedStateGetterCount = 0
	var stubbedState: ScanLockManager.State!

	var state: ScanLockManager.State {
		invokedStateGetter = true
		invokedStateGetterCount += 1
		return stubbedState
	}

	var invokedLock = false
	var invokedLockCount = 0

	func lock() {
		invokedLock = true
		invokedLockCount += 1
	}

	var invokedAppendObserver = false
	var invokedAppendObserverCount = 0
	var stubbedAppendObserverObserverResult: (ScanLockManager.State, Void)?
	var stubbedAppendObserverResult: ScanLockManager.ObserverToken!

	func appendObserver(_ observer: @escaping (ScanLockManager.State) -> Void) -> ScanLockManager.ObserverToken {
		invokedAppendObserver = true
		invokedAppendObserverCount += 1
		if let result = stubbedAppendObserverObserverResult {
			observer(result.0)
		}
		return stubbedAppendObserverResult
	}

	var invokedRemoveObserver = false
	var invokedRemoveObserverCount = 0
	var invokedRemoveObserverParameters: (token: ScanLockManager.ObserverToken, Void)?
	var invokedRemoveObserverParametersList = [(token: ScanLockManager.ObserverToken, Void)]()

	func removeObserver(token: ScanLockManager.ObserverToken) {
		invokedRemoveObserver = true
		invokedRemoveObserverCount += 1
		invokedRemoveObserverParameters = (token, ())
		invokedRemoveObserverParametersList.append((token, ()))
	}
}

extension ScanLockManagerSpy {
	static var configScanLockDuration: TimeInterval { return 30 }
}
