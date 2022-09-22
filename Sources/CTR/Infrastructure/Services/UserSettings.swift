/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol UserSettingsProtocol: AnyObject {

	var scanInstructionShown: Bool { get set }

	var jailbreakWarningShown: Bool { get set }

	var dashboardRegionToggleValue: QRCodeValidityRegion { get set }

	var configFetchedTimestamp: TimeInterval? { get set }

	var configFetchedHash: String? { get set }

	var lastScreenshotTime: Date? { get set }

	var issuerKeysFetchedTimestamp: TimeInterval? { get set }

	var lastRecommendUpdateDismissalTimestamp: TimeInterval? { get set }
	
	var lastSeenRecommendedUpdate: String? { get set }

	var lastSuccessfulCompletionOfAddCertificateFlowDate: Date? { get set }
	
	var deviceAuthenticationWarningShown: Bool { get set }
	
	var configVerificationPolicies: [VerificationPolicy] { get set }
	
	var policyInformationShown: Bool { get set }

	var lastDismissedDisclosurePolicy: [DisclosurePolicy] { get set }
	var hasDismissedZeroGPolicy: Bool { get set }
	var lastKnownConfigDisclosurePolicy: [String] { get set }
	var overrideDisclosurePolicies: [String] { get set }

	var hasShownBlockedEventsAlert: Bool { get set }
	
	func wipePersistedData()
}

class UserSettings: UserSettingsProtocol {

	@UserDefaults(key: "scanInstructionShown", defaultValue: false)
	var scanInstructionShown: Bool

	@UserDefaults(key: "jailbreakWarningShown", defaultValue: false)
	var jailbreakWarningShown: Bool

	@UserDefaults(key: "dashboardRegionToggleValue")
	var dashboardRegionToggleValue: QRCodeValidityRegion = .domestic

	@UserDefaults(key: "configFetchedTimestamp", defaultValue: nil)
	var configFetchedTimestamp: TimeInterval?

	@UserDefaults(key: "configFetchedHash", defaultValue: nil)
	var configFetchedHash: String?

	@UserDefaults(key: "issuerKeysFetchedTimestamp", defaultValue: nil)
	var issuerKeysFetchedTimestamp: TimeInterval?

	@UserDefaults(key: "lastScreenshotTime", defaultValue: nil)
	var lastScreenshotTime: Date?

	@UserDefaults(key: "lastRecommendUpdateDismissalTimestamp", defaultValue: nil)
	var lastRecommendUpdateDismissalTimestamp: TimeInterval?

	@UserDefaults(key: "lastSeenRecommendedUpdate", defaultValue: nil)
	var lastSeenRecommendedUpdate: String?
	
	@UserDefaults(key: "lastSuccessfulCompletionOfAddCertificateFlowDate", defaultValue: nil)
	var lastSuccessfulCompletionOfAddCertificateFlowDate: Date?

	@UserDefaults(key: "deviceAuthenticationWarningShown", defaultValue: false)
	var deviceAuthenticationWarningShown: Bool
	
	@UserDefaults(key: "configVerificationPolicies")
	var configVerificationPolicies: [VerificationPolicy] = []
	
	@UserDefaults(key: "policyInformationShown", defaultValue: false)
	var policyInformationShown: Bool

	@UserDefaults(key: "lastDismissedDisclosurePolicy")
	var lastDismissedDisclosurePolicy: [DisclosurePolicy] = []

	@UserDefaults(key: "hasDismissedZeroGPolicy") // special-case because `lastDismissedDisclosurePolicy` was released with `defaultValue: []`
	var hasDismissedZeroGPolicy: Bool = false
	
	@UserDefaults(key: "overrideDisclosurePolicies")
	var overrideDisclosurePolicies: [String] = []
	
	@UserDefaults(key: "lastKnownConfigDisclosurePolicy")
	var lastKnownConfigDisclosurePolicy: [String] = ["3G"]
	
	// The alert which tells the user that one of their certificates has been blocked:
	@UserDefaults(key: "hasShownBlockedEventsAlert")
	var hasShownBlockedEventsAlert: Bool = false
}

extension UserSettings {

	func wipePersistedData() {
		
		// Clear user defaults:
		// We can not simply loop over all the keys, as some are needed for clear on reinstall for the keychain items.
		let userDefaults = Foundation.UserDefaults.standard
		[	"scanInstructionShown",
			"jailbreakWarningShown",
			"dashboardRegionToggleValue",
			"configFetchedTimestamp",
			"configFetchedHash",
			"issuerKeysFetchedTimestamp",
			"lastScreenshotTime",
			"lastRecommendUpdateDismissalTimestamp",
			"lastSeenRecommendedUpdate",
			"lastSuccessfulCompletionOfAddCertificateFlowDate",
			"deviceAuthenticationWarningShown",
			"deviceAuthenticationWarningShown",
			"shouldCheckRecoveryGreenCardRevisedValidity",
			"configVerificationPolicies",
			"policyInformationShown",
			"lastDismissedDisclosurePolicy",
			"overrideDisclosurePolicies",
			"lastKnownConfigDisclosurePolicy",
			"hasDismissedZeroGPolicy",
			"hasShownBlockedEventsAlert",

			// Deprecated keys
			"hasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard",
			"shouldCheckNewValidityInfoForVaccinationsAndRecoveriesCard",
			"lastRecommendToAddYourBoosterDismissalDate",
			"shouldShowRecoveryValidityExtensionCard",
			"shouldShowRecoveryValidityReinstationCard",
			"hasDismissedRecoveryValidityExtensionCompletionCard",
			"hasDismissedRecoveryValidityReinstationCompletionCard",
			"didCompleteEUVaccinationMigration",
			"didDismissEUVaccinationMigrationSuccessBanner"
		].forEach(userDefaults.removeObject(forKey:))
	}
}
