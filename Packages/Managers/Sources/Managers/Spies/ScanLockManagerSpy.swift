/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

extension ScanLockManagerSpy {
	static public var configScanLockDuration: TimeInterval {
		return 10
	}
}

public class ScanLockManagerSpy: ScanLockManaging {
	
	public init() {}

	public var invokedStateGetter = false
	public var invokedStateGetterCount = 0
	public var stubbedState: ScanLockManager.State!

	public var state: ScanLockManager.State {
		invokedStateGetter = true
		invokedStateGetterCount += 1
		return stubbedState
	}

	public var invokedObservatoryGetter = false
	public var invokedObservatoryGetterCount = 0
	public var stubbedObservatory: Observatory<ScanLockManager.State>!

	public var observatory: Observatory<ScanLockManager.State> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	public var invokedConfigScanLockDurationGetter = false
	public var invokedConfigScanLockDurationGetterCount = 0
	public var stubbedConfigScanLockDuration: TimeInterval!

	public var configScanLockDuration: TimeInterval {
		invokedConfigScanLockDurationGetter = true
		invokedConfigScanLockDurationGetterCount += 1
		return stubbedConfigScanLockDuration
	}

	public var invokedLock = false
	public var invokedLockCount = 0

	public func lock() {
		invokedLock = true
		invokedLockCount += 1
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
