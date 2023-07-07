/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

public class UserSettingsSpy: UserSettingsProtocol {
	
	public init() {}

	public var invokedScanInstructionShownSetter = false
	public var invokedScanInstructionShownSetterCount = 0
	public var invokedScanInstructionShown: Bool?
	public var invokedScanInstructionShownList = [Bool]()
	public var invokedScanInstructionShownGetter = false
	public var invokedScanInstructionShownGetterCount = 0
	public var stubbedScanInstructionShown: Bool! = false

	public var scanInstructionShown: Bool {
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

	public var invokedJailbreakWarningShownSetter = false
	public var invokedJailbreakWarningShownSetterCount = 0
	public var invokedJailbreakWarningShown: Bool?
	public var invokedJailbreakWarningShownList = [Bool]()
	public var invokedJailbreakWarningShownGetter = false
	public var invokedJailbreakWarningShownGetterCount = 0
	public var stubbedJailbreakWarningShown: Bool! = false

	public var jailbreakWarningShown: Bool {
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

	public var invokedConfigFetchedTimestampSetter = false
	public var invokedConfigFetchedTimestampSetterCount = 0
	public var invokedConfigFetchedTimestamp: TimeInterval?
	public var invokedConfigFetchedTimestampList = [TimeInterval?]()
	public var invokedConfigFetchedTimestampGetter = false
	public var invokedConfigFetchedTimestampGetterCount = 0
	public var stubbedConfigFetchedTimestamp: TimeInterval!

	public var configFetchedTimestamp: TimeInterval? {
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

	public var invokedConfigFetchedHashSetter = false
	public var invokedConfigFetchedHashSetterCount = 0
	public var invokedConfigFetchedHash: String?
	public var invokedConfigFetchedHashList = [String?]()
	public var invokedConfigFetchedHashGetter = false
	public var invokedConfigFetchedHashGetterCount = 0
	public var stubbedConfigFetchedHash: String!

	public var configFetchedHash: String? {
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

	public var invokedLastScreenshotTimeSetter = false
	public var invokedLastScreenshotTimeSetterCount = 0
	public var invokedLastScreenshotTime: Date?
	public var invokedLastScreenshotTimeList = [Date?]()
	public var invokedLastScreenshotTimeGetter = false
	public var invokedLastScreenshotTimeGetterCount = 0
	public var stubbedLastScreenshotTime: Date!

	public var lastScreenshotTime: Date? {
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

	public var invokedIssuerKeysFetchedTimestampSetter = false
	public var invokedIssuerKeysFetchedTimestampSetterCount = 0
	public var invokedIssuerKeysFetchedTimestamp: TimeInterval?
	public var invokedIssuerKeysFetchedTimestampList = [TimeInterval?]()
	public var invokedIssuerKeysFetchedTimestampGetter = false
	public var invokedIssuerKeysFetchedTimestampGetterCount = 0
	public var stubbedIssuerKeysFetchedTimestamp: TimeInterval!

	public var issuerKeysFetchedTimestamp: TimeInterval? {
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

	public var invokedLastRecommendUpdateDismissalTimestampSetter = false
	public var invokedLastRecommendUpdateDismissalTimestampSetterCount = 0
	public var invokedLastRecommendUpdateDismissalTimestamp: TimeInterval?
	public var invokedLastRecommendUpdateDismissalTimestampList = [TimeInterval?]()
	public var invokedLastRecommendUpdateDismissalTimestampGetter = false
	public var invokedLastRecommendUpdateDismissalTimestampGetterCount = 0
	public var stubbedLastRecommendUpdateDismissalTimestamp: TimeInterval!

	public var lastRecommendUpdateDismissalTimestamp: TimeInterval? {
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

	public var invokedLastSeenRecommendedUpdateSetter = false
	public var invokedLastSeenRecommendedUpdateSetterCount = 0
	public var invokedLastSeenRecommendedUpdate: String?
	public var invokedLastSeenRecommendedUpdateList = [String?]()
	public var invokedLastSeenRecommendedUpdateGetter = false
	public var invokedLastSeenRecommendedUpdateGetterCount = 0
	public var stubbedLastSeenRecommendedUpdate: String!

	public var lastSeenRecommendedUpdate: String? {
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

	public var invokedLastSuccessfulCompletionOfAddCertificateFlowDateSetter = false
	public var invokedLastSuccessfulCompletionOfAddCertificateFlowDateSetterCount = 0
	public var invokedLastSuccessfulCompletionOfAddCertificateFlowDate: Date?
	public var invokedLastSuccessfulCompletionOfAddCertificateFlowDateList = [Date?]()
	public var invokedLastSuccessfulCompletionOfAddCertificateFlowDateGetter = false
	public var invokedLastSuccessfulCompletionOfAddCertificateFlowDateGetterCount = 0
	public var stubbedLastSuccessfulCompletionOfAddCertificateFlowDate: Date!

	public var lastSuccessfulCompletionOfAddCertificateFlowDate: Date? {
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

	public var invokedDeviceAuthenticationWarningShownSetter = false
	public var invokedDeviceAuthenticationWarningShownSetterCount = 0
	public var invokedDeviceAuthenticationWarningShown: Bool?
	public var invokedDeviceAuthenticationWarningShownList = [Bool]()
	public var invokedDeviceAuthenticationWarningShownGetter = false
	public var invokedDeviceAuthenticationWarningShownGetterCount = 0
	public var stubbedDeviceAuthenticationWarningShown: Bool! = false

	public var deviceAuthenticationWarningShown: Bool {
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

	public var invokedConfigVerificationPoliciesSetter = false
	public var invokedConfigVerificationPoliciesSetterCount = 0
	public var invokedConfigVerificationPolicies: [VerificationPolicy]?
	public var invokedConfigVerificationPoliciesList = [[VerificationPolicy]]()
	public var invokedConfigVerificationPoliciesGetter = false
	public var invokedConfigVerificationPoliciesGetterCount = 0
	public var stubbedConfigVerificationPolicies: [VerificationPolicy]! = []

	public var configVerificationPolicies: [VerificationPolicy] {
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

	public var invokedPolicyInformationShownSetter = false
	public var invokedPolicyInformationShownSetterCount = 0
	public var invokedPolicyInformationShown: Bool?
	public var invokedPolicyInformationShownList = [Bool]()
	public var invokedPolicyInformationShownGetter = false
	public var invokedPolicyInformationShownGetterCount = 0
	public var stubbedPolicyInformationShown: Bool! = false

	public var policyInformationShown: Bool {
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

	public var invokedHasDismissedZeroGPolicySetter = false
	public var invokedHasDismissedZeroGPolicySetterCount = 0
	public var invokedHasDismissedZeroGPolicy: Bool?
	public var invokedHasDismissedZeroGPolicyList = [Bool]()
	public var invokedHasDismissedZeroGPolicyGetter = false
	public var invokedHasDismissedZeroGPolicyGetterCount = 0
	public var stubbedHasDismissedZeroGPolicy: Bool! = false

	public var hasDismissedZeroGPolicy: Bool {
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

	public var invokedHasShownBlockedEventsAlertSetter = false
	public var invokedHasShownBlockedEventsAlertSetterCount = 0
	public var invokedHasShownBlockedEventsAlert: Bool?
	public var invokedHasShownBlockedEventsAlertList = [Bool]()
	public var invokedHasShownBlockedEventsAlertGetter = false
	public var invokedHasShownBlockedEventsAlertGetterCount = 0
	public var stubbedHasShownBlockedEventsAlert: Bool! = false

	public var hasShownBlockedEventsAlert: Bool {
		set {
			invokedHasShownBlockedEventsAlertSetter = true
			invokedHasShownBlockedEventsAlertSetterCount += 1
			invokedHasShownBlockedEventsAlert = newValue
			invokedHasShownBlockedEventsAlertList.append(newValue)
		}
		get {
			invokedHasShownBlockedEventsAlertGetter = true
			invokedHasShownBlockedEventsAlertGetterCount += 1
			return stubbedHasShownBlockedEventsAlert
		}
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
