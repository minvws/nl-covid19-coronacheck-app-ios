/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class UserSettingsSpy: UserSettingsProtocol {

	var invokedScanInstructionShownSetter = false
	var invokedScanInstructionShownSetterCount = 0
	var invokedScanInstructionShown: Bool?
	var invokedScanInstructionShownList = [Bool]()
	var invokedScanInstructionShownGetter = false
	var invokedScanInstructionShownGetterCount = 0
	var stubbedScanInstructionShown: Bool! = false

	var scanInstructionShown: Bool {
		get {
			invokedScanInstructionShownGetter = true
			invokedScanInstructionShownGetterCount += 1
			return stubbedScanInstructionShown
		}
		set {
			invokedScanInstructionShownSetter = true
			invokedScanInstructionShownSetterCount += 1
			invokedScanInstructionShown = newValue
			invokedScanInstructionShownList.append(newValue)
		}
	}

	var invokedJailbreakWarningShownSetter = false
	var invokedJailbreakWarningShownSetterCount = 0
	var invokedJailbreakWarningShown: Bool?
	var invokedJailbreakWarningShownList = [Bool]()
	var invokedJailbreakWarningShownGetter = false
	var invokedJailbreakWarningShownGetterCount = 0
	var stubbedJailbreakWarningShown: Bool! = false

	var jailbreakWarningShown: Bool {
		get {
			invokedJailbreakWarningShownGetter = true
			invokedJailbreakWarningShownGetterCount += 1
			return stubbedJailbreakWarningShown
		}
		set {
			invokedJailbreakWarningShownSetter = true
			invokedJailbreakWarningShownSetterCount += 1
			invokedJailbreakWarningShown = newValue
			invokedJailbreakWarningShownList.append(newValue)
		}
	}
}
