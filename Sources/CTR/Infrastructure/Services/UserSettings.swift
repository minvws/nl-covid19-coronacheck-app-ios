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

	func wipePersistedData()
}

class UserSettings: UserSettingsProtocol {

	@UserDefaults(key: "scanInstructionShown", defaultValue: false)
	var scanInstructionShown: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "jailbreakWarningShown", defaultValue: false)
	var jailbreakWarningShown: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "dashboardRegionToggleValue")
	var dashboardRegionToggleValue: QRCodeValidityRegion = .domestic // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "configFetchedTimestamp", defaultValue: nil)
	var configFetchedTimestamp: TimeInterval? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "configFetchedHash", defaultValue: nil)
	var configFetchedHash: String? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "issuerKeysFetchedTimestamp", defaultValue: nil)
	var issuerKeysFetchedTimestamp: TimeInterval? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "lastScreenshotTime", defaultValue: nil)
	var lastScreenshotTime: Date? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "lastRecommendUpdateDismissalTimestamp", defaultValue: nil)
	var lastRecommendUpdateDismissalTimestamp: TimeInterval? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "lastSeenRecommendedUpdate", defaultValue: nil)
	var lastSeenRecommendedUpdate: String? // swiftlint:disable:this let_var_whitespace
	
	@UserDefaults(key: "lastSuccessfulCompletionOfAddCertificateFlowDate", defaultValue: nil)
	var lastSuccessfulCompletionOfAddCertificateFlowDate: Date? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "deviceAuthenticationWarningShown", defaultValue: false)
	var deviceAuthenticationWarningShown: Bool // swiftlint:disable:this let_var_whitespace
	
	@UserDefaults(key: "configVerificationPolicies")
	var configVerificationPolicies: [VerificationPolicy] = [] // swiftlint:disable:this let_var_whitespace
	
	@UserDefaults(key: "policyInformationShown", defaultValue: false)
	var policyInformationShown: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "lastDismissedDisclosurePolicy")
	var lastDismissedDisclosurePolicy: [DisclosurePolicy] = [] // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "hasDismissedZeroGPolicy") // special-case because `lastDismissedDisclosurePolicy` was released with `defaultValue: []`
	var hasDismissedZeroGPolicy: Bool = false
	
	@UserDefaults(key: "overrideDisclosurePolicies")
	var overrideDisclosurePolicies: [String] = [] // swiftlint:disable:this let_var_whitespace
	
	@UserDefaults(key: "lastKnownConfigDisclosurePolicy")
	var lastKnownConfigDisclosurePolicy: [String] = ["3G"] // swiftlint:disable:this let_var_whitespace
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
