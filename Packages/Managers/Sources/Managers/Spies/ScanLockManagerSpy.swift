/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

extension ScanLockManagerSpy {
	static var configScanLockDuration: TimeInterval {
		return 10
	}
}

class ScanLockManagerSpy: ScanLockManaging {

	var invokedStateGetter = false
	var invokedStateGetterCount = 0
	var stubbedState: ScanLockManager.State!

	var state: ScanLockManager.State {
		invokedStateGetter = true
		invokedStateGetterCount += 1
		return stubbedState
	}

	var invokedObservatoryGetter = false
	var invokedObservatoryGetterCount = 0
	var stubbedObservatory: Observatory<ScanLockManager.State>!

	var observatory: Observatory<ScanLockManager.State> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	var invokedConfigScanLockDurationGetter = false
	var invokedConfigScanLockDurationGetterCount = 0
	var stubbedConfigScanLockDuration: TimeInterval!

	var configScanLockDuration: TimeInterval {
		invokedConfigScanLockDurationGetter = true
		invokedConfigScanLockDurationGetterCount += 1
		return stubbedConfigScanLockDuration
	}

	var invokedLock = false
	var invokedLockCount = 0

	func lock() {
		invokedLock = true
		invokedLockCount += 1
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
