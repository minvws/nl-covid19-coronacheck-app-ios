/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

class SecureUserSettingsSpy: SecureUserSettingsProtocol {

	var invokedScanLockUntilSetter = false
	var invokedScanLockUntilSetterCount = 0
	var invokedScanLockUntil: Date?
	var invokedScanLockUntilList = [Date]()
	var invokedScanLockUntilGetter = false
	var invokedScanLockUntilGetterCount = 0
	var stubbedScanLockUntil: Date!

	var scanLockUntil: Date {
		set {
			invokedScanLockUntilSetter = true
			invokedScanLockUntilSetterCount += 1
			invokedScanLockUntil = newValue
			invokedScanLockUntilList.append(newValue)
		}
		get {
			invokedScanLockUntilGetter = true
			invokedScanLockUntilGetterCount += 1
			return stubbedScanLockUntil
		}
	}

	var invokedReset = false
	var invokedResetCount = 0

	func reset() {
		invokedReset = true
		invokedResetCount += 1
	}
}
