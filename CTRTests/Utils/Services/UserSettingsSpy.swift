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
		set {
			invokedScanInstructionShownSetter = true
			invokedScanInstructionShownSetterCount += 1
			invokedScanInstructionShown = newValue
			invokedScanInstructionShownList.append(newValue)
		}
		get {
			invokedScanInstructionShownGetter = true
			invokedScanInstructionShownGetterCount += 1
			return stubbedScanInstructionShown
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
		set {
			invokedJailbreakWarningShownSetter = true
			invokedJailbreakWarningShownSetterCount += 1
			invokedJailbreakWarningShown = newValue
			invokedJailbreakWarningShownList.append(newValue)
		}
		get {
			invokedJailbreakWarningShownGetter = true
			invokedJailbreakWarningShownGetterCount += 1
			return stubbedJailbreakWarningShown
		}
	}

	var invokedDashboardRegionToggleValueSetter = false
	var invokedDashboardRegionToggleValueSetterCount = 0
	var invokedDashboardRegionToggleValue: QRCodeValidityRegion?
	var invokedDashboardRegionToggleValueList = [QRCodeValidityRegion]()
	var invokedDashboardRegionToggleValueGetter = false
	var invokedDashboardRegionToggleValueGetterCount = 0
	var stubbedDashboardRegionToggleValue: QRCodeValidityRegion!

	var dashboardRegionToggleValue: QRCodeValidityRegion {
		set {
			invokedDashboardRegionToggleValueSetter = true
			invokedDashboardRegionToggleValueSetterCount += 1
			invokedDashboardRegionToggleValue = newValue
			invokedDashboardRegionToggleValueList.append(newValue)
		}
		get {
			invokedDashboardRegionToggleValueGetter = true
			invokedDashboardRegionToggleValueGetterCount += 1
			return stubbedDashboardRegionToggleValue
		}
	}
}
