/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	var invokedConfigFetchedTimestamp: TimeInterval?
	var invokedConfigFetchedTimestampList = [TimeInterval?]()
	var invokedConfigFetchedTimestampGetter = false
	var invokedConfigFetchedTimestampGetterCount = 0
	var stubbedConfigFetchedTimestamp: TimeInterval!

	var configFetchedTimestamp: TimeInterval? {
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

	var invokedConfigFetchedHashSetter = false
	var invokedConfigFetchedHashSetterCount = 0
	var invokedConfigFetchedHash: String?
	var invokedConfigFetchedHashList = [String?]()
	var invokedConfigFetchedHashGetter = false
	var invokedConfigFetchedHashGetterCount = 0
	var stubbedConfigFetchedHash: String!

	var configFetchedHash: String? {
		set {
			invokedConfigFetchedHashSetter = true
			invokedConfigFetchedHashSetterCount += 1
			invokedConfigFetchedHash = newValue
			invokedConfigFetchedHashList.append(newValue)
		}
		get {
			invokedConfigFetchedHashGetter = true
			invokedConfigFetchedHashGetterCount += 1
			return stubbedConfigFetchedHash
		}
	}

	var invokedLastScreenshotTimeSetter = false
	var invokedLastScreenshotTimeSetterCount = 0
	var invokedLastScreenshotTime: Date?
	var invokedLastScreenshotTimeList = [Date?]()
	var invokedLastScreenshotTimeGetter = false
	var invokedLastScreenshotTimeGetterCount = 0
	var stubbedLastScreenshotTime: Date!

	var lastScreenshotTime: Date? {
		set {
			invokedLastScreenshotTimeSetter = true
			invokedLastScreenshotTimeSetterCount += 1
			invokedLastScreenshotTime = newValue
			invokedLastScreenshotTimeList.append(newValue)
		}
		get {
			invokedLastScreenshotTimeGetter = true
			invokedLastScreenshotTimeGetterCount += 1
			return stubbedLastScreenshotTime
		}
	}

	var invokedIssuerKeysFetchedTimestampSetter = false
	var invokedIssuerKeysFetchedTimestampSetterCount = 0
	var invokedIssuerKeysFetchedTimestamp: TimeInterval?
	var invokedIssuerKeysFetchedTimestampList = [TimeInterval?]()
	var invokedIssuerKeysFetchedTimestampGetter = false
	var invokedIssuerKeysFetchedTimestampGetterCount = 0
	var stubbedIssuerKeysFetchedTimestamp: TimeInterval!

	var issuerKeysFetchedTimestamp: TimeInterval? {
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

	var invokedLastRecommendUpdateDismissalTimestampSetter = false
	var invokedLastRecommendUpdateDismissalTimestampSetterCount = 0
	var invokedLastRecommendUpdateDismissalTimestamp: TimeInterval?
	var invokedLastRecommendUpdateDismissalTimestampList = [TimeInterval?]()
	var invokedLastRecommendUpdateDismissalTimestampGetter = false
	var invokedLastRecommendUpdateDismissalTimestampGetterCount = 0
	var stubbedLastRecommendUpdateDismissalTimestamp: TimeInterval!

	var lastRecommendUpdateDismissalTimestamp: TimeInterval? {
		set {
			invokedLastRecommendUpdateDismissalTimestampSetter = true
			invokedLastRecommendUpdateDismissalTimestampSetterCount += 1
			invokedLastRecommendUpdateDismissalTimestamp = newValue
			invokedLastRecommendUpdateDismissalTimestampList.append(newValue)
		}
		get {
			invokedLastRecommendUpdateDismissalTimestampGetter = true
			invokedLastRecommendUpdateDismissalTimestampGetterCount += 1
			return stubbedLastRecommendUpdateDismissalTimestamp
		}
	}

	var invokedLastSeenRecommendedUpdateSetter = false
	var invokedLastSeenRecommendedUpdateSetterCount = 0
	var invokedLastSeenRecommendedUpdate: String?
	var invokedLastSeenRecommendedUpdateList = [String?]()
	var invokedLastSeenRecommendedUpdateGetter = false
	var invokedLastSeenRecommendedUpdateGetterCount = 0
	var stubbedLastSeenRecommendedUpdate: String!

	var lastSeenRecommendedUpdate: String? {
		set {
			invokedLastSeenRecommendedUpdateSetter = true
			invokedLastSeenRecommendedUpdateSetterCount += 1
			invokedLastSeenRecommendedUpdate = newValue
			invokedLastSeenRecommendedUpdateList.append(newValue)
		}
		get {
			invokedLastSeenRecommendedUpdateGetter = true
			invokedLastSeenRecommendedUpdateGetterCount += 1
			return stubbedLastSeenRecommendedUpdate
		}
	}

	var invokedLastSuccessfulCompletionOfAddCertificateFlowDateSetter = false
	var invokedLastSuccessfulCompletionOfAddCertificateFlowDateSetterCount = 0
	var invokedLastSuccessfulCompletionOfAddCertificateFlowDate: Date?
	var invokedLastSuccessfulCompletionOfAddCertificateFlowDateList = [Date?]()
	var invokedLastSuccessfulCompletionOfAddCertificateFlowDateGetter = false
	var invokedLastSuccessfulCompletionOfAddCertificateFlowDateGetterCount = 0
	var stubbedLastSuccessfulCompletionOfAddCertificateFlowDate: Date!

	var lastSuccessfulCompletionOfAddCertificateFlowDate: Date? {
		set {
			invokedLastSuccessfulCompletionOfAddCertificateFlowDateSetter = true
			invokedLastSuccessfulCompletionOfAddCertificateFlowDateSetterCount += 1
			invokedLastSuccessfulCompletionOfAddCertificateFlowDate = newValue
			invokedLastSuccessfulCompletionOfAddCertificateFlowDateList.append(newValue)
		}
		get {
			invokedLastSuccessfulCompletionOfAddCertificateFlowDateGetter = true
			invokedLastSuccessfulCompletionOfAddCertificateFlowDateGetterCount += 1
			return stubbedLastSuccessfulCompletionOfAddCertificateFlowDate
		}
	}

	var invokedDeviceAuthenticationWarningShownSetter = false
	var invokedDeviceAuthenticationWarningShownSetterCount = 0
	var invokedDeviceAuthenticationWarningShown: Bool?
	var invokedDeviceAuthenticationWarningShownList = [Bool]()
	var invokedDeviceAuthenticationWarningShownGetter = false
	var invokedDeviceAuthenticationWarningShownGetterCount = 0
	var stubbedDeviceAuthenticationWarningShown: Bool! = false

	var deviceAuthenticationWarningShown: Bool {
		set {
			invokedDeviceAuthenticationWarningShownSetter = true
			invokedDeviceAuthenticationWarningShownSetterCount += 1
			invokedDeviceAuthenticationWarningShown = newValue
			invokedDeviceAuthenticationWarningShownList.append(newValue)
		}
		get {
			invokedDeviceAuthenticationWarningShownGetter = true
			invokedDeviceAuthenticationWarningShownGetterCount += 1
			return stubbedDeviceAuthenticationWarningShown
		}
	}

	var invokedConfigVerificationPoliciesSetter = false
	var invokedConfigVerificationPoliciesSetterCount = 0
	var invokedConfigVerificationPolicies: [VerificationPolicy]?
	var invokedConfigVerificationPoliciesList = [[VerificationPolicy]]()
	var invokedConfigVerificationPoliciesGetter = false
	var invokedConfigVerificationPoliciesGetterCount = 0
	var stubbedConfigVerificationPolicies: [VerificationPolicy]! = []

	var configVerificationPolicies: [VerificationPolicy] {
		set {
			invokedConfigVerificationPoliciesSetter = true
			invokedConfigVerificationPoliciesSetterCount += 1
			invokedConfigVerificationPolicies = newValue
			invokedConfigVerificationPoliciesList.append(newValue)
		}
		get {
			invokedConfigVerificationPoliciesGetter = true
			invokedConfigVerificationPoliciesGetterCount += 1
			return stubbedConfigVerificationPolicies
		}
	}

	var invokedPolicyInformationShownSetter = false
	var invokedPolicyInformationShownSetterCount = 0
	var invokedPolicyInformationShown: Bool?
	var invokedPolicyInformationShownList = [Bool]()
	var invokedPolicyInformationShownGetter = false
	var invokedPolicyInformationShownGetterCount = 0
	var stubbedPolicyInformationShown: Bool! = false

	var policyInformationShown: Bool {
		set {
			invokedPolicyInformationShownSetter = true
			invokedPolicyInformationShownSetterCount += 1
			invokedPolicyInformationShown = newValue
			invokedPolicyInformationShownList.append(newValue)
		}
		get {
			invokedPolicyInformationShownGetter = true
			invokedPolicyInformationShownGetterCount += 1
			return stubbedPolicyInformationShown
		}
	}

	var invokedLastDismissedDisclosurePolicySetter = false
	var invokedLastDismissedDisclosurePolicySetterCount = 0
	var invokedLastDismissedDisclosurePolicy: [DisclosurePolicy]?
	var invokedLastDismissedDisclosurePolicyList = [[DisclosurePolicy]]()
	var invokedLastDismissedDisclosurePolicyGetter = false
	var invokedLastDismissedDisclosurePolicyGetterCount = 0
	var stubbedLastDismissedDisclosurePolicy: [DisclosurePolicy]! = []

	var lastDismissedDisclosurePolicy: [DisclosurePolicy] {
		set {
			invokedLastDismissedDisclosurePolicySetter = true
			invokedLastDismissedDisclosurePolicySetterCount += 1
			invokedLastDismissedDisclosurePolicy = newValue
			invokedLastDismissedDisclosurePolicyList.append(newValue)
		}
		get {
			invokedLastDismissedDisclosurePolicyGetter = true
			invokedLastDismissedDisclosurePolicyGetterCount += 1
			return stubbedLastDismissedDisclosurePolicy
		}
	}

	var invokedHasDismissedZeroGPolicySetter = false
	var invokedHasDismissedZeroGPolicySetterCount = 0
	var invokedHasDismissedZeroGPolicy: Bool?
	var invokedHasDismissedZeroGPolicyList = [Bool]()
	var invokedHasDismissedZeroGPolicyGetter = false
	var invokedHasDismissedZeroGPolicyGetterCount = 0
	var stubbedHasDismissedZeroGPolicy: Bool! = false

	var hasDismissedZeroGPolicy: Bool {
		set {
			invokedHasDismissedZeroGPolicySetter = true
			invokedHasDismissedZeroGPolicySetterCount += 1
			invokedHasDismissedZeroGPolicy = newValue
			invokedHasDismissedZeroGPolicyList.append(newValue)
		}
		get {
			invokedHasDismissedZeroGPolicyGetter = true
			invokedHasDismissedZeroGPolicyGetterCount += 1
			return stubbedHasDismissedZeroGPolicy
		}
	}

	var invokedLastKnownConfigDisclosurePolicySetter = false
	var invokedLastKnownConfigDisclosurePolicySetterCount = 0
	var invokedLastKnownConfigDisclosurePolicy: [String]?
	var invokedLastKnownConfigDisclosurePolicyList = [[String]]()
	var invokedLastKnownConfigDisclosurePolicyGetter = false
	var invokedLastKnownConfigDisclosurePolicyGetterCount = 0
	var stubbedLastKnownConfigDisclosurePolicy: [String]! = []

	var lastKnownConfigDisclosurePolicy: [String] {
		set {
			invokedLastKnownConfigDisclosurePolicySetter = true
			invokedLastKnownConfigDisclosurePolicySetterCount += 1
			invokedLastKnownConfigDisclosurePolicy = newValue
			invokedLastKnownConfigDisclosurePolicyList.append(newValue)
		}
		get {
			invokedLastKnownConfigDisclosurePolicyGetter = true
			invokedLastKnownConfigDisclosurePolicyGetterCount += 1
			return stubbedLastKnownConfigDisclosurePolicy
		}
	}

	var invokedOverrideDisclosurePoliciesSetter = false
	var invokedOverrideDisclosurePoliciesSetterCount = 0
	var invokedOverrideDisclosurePolicies: [String]?
	var invokedOverrideDisclosurePoliciesList = [[String]]()
	var invokedOverrideDisclosurePoliciesGetter = false
	var invokedOverrideDisclosurePoliciesGetterCount = 0
	var stubbedOverrideDisclosurePolicies: [String]! = []

	var overrideDisclosurePolicies: [String] {
		set {
			invokedOverrideDisclosurePoliciesSetter = true
			invokedOverrideDisclosurePoliciesSetterCount += 1
			invokedOverrideDisclosurePolicies = newValue
			invokedOverrideDisclosurePoliciesList.append(newValue)
		}
		get {
			invokedOverrideDisclosurePoliciesGetter = true
			invokedOverrideDisclosurePoliciesGetterCount += 1
			return stubbedOverrideDisclosurePolicies
		}
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
