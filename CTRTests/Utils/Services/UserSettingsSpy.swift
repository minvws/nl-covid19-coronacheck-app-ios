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

	var invokedConfigFetchedTimestampSetter = false
	var invokedConfigFetchedTimestampSetterCount = 0
	var invokedConfigFetchedTimestamp: Date?
	var invokedConfigFetchedTimestampList = [Date?]()
	var invokedConfigFetchedTimestampGetter = false
	var invokedConfigFetchedTimestampGetterCount = 0
	var stubbedConfigFetchedTimestamp: Date!

	var configFetchedTimestamp: Date? {
		set {
			invokedConfigFetchedTimestampSetter = true
			invokedConfigFetchedTimestampSetterCount += 1
			invokedConfigFetchedTimestamp = newValue
			invokedConfigFetchedTimestampList.append(newValue)
		}
		get {
			invokedConfigFetchedTimestampGetter = true
			invokedConfigFetchedTimestampGetterCount += 1
			return stubbedConfigFetchedTimestamp
		}
	}

	var invokedIssuerKeysFetchedTimestampSetter = false
	var invokedIssuerKeysFetchedTimestampSetterCount = 0
	var invokedIssuerKeysFetchedTimestamp: Date?
	var invokedIssuerKeysFetchedTimestampList = [Date?]()
	var invokedIssuerKeysFetchedTimestampGetter = false
	var invokedIssuerKeysFetchedTimestampGetterCount = 0
	var stubbedIssuerKeysFetchedTimestamp: Date!

	var issuerKeysFetchedTimestamp: Date? {
		set {
			invokedIssuerKeysFetchedTimestampSetter = true
			invokedIssuerKeysFetchedTimestampSetterCount += 1
			invokedIssuerKeysFetchedTimestamp = newValue
			invokedIssuerKeysFetchedTimestampList.append(newValue)
		}
		get {
			invokedIssuerKeysFetchedTimestampGetter = true
			invokedIssuerKeysFetchedTimestampGetterCount += 1
			return stubbedIssuerKeysFetchedTimestamp
		}
	}
}
