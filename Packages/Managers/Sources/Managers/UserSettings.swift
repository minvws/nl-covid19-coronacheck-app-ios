/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Models

public protocol UserSettingsProtocol: AnyObject {

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

	var hasDismissedZeroGPolicy: Bool { get set }
	var lastKnownConfigDisclosurePolicy: [String] { get set }
	var overrideDisclosurePolicies: [String] { get set }

	var hasShownBlockedEventsAlert: Bool { get set }
	
	func wipePersistedData()
}

public class UserSettings: UserSettingsProtocol {

	public init() {}
	
	@Shared.UserDefaults(key: "scanInstructionShown", defaultValue: false)
	public var scanInstructionShown: Bool

	@Shared.UserDefaults(key: "jailbreakWarningShown", defaultValue: false)
	public var jailbreakWarningShown: Bool

	@Shared.UserDefaults(key: "dashboardRegionToggleValue")
	public var dashboardRegionToggleValue: QRCodeValidityRegion = .domestic

	@Shared.UserDefaults(key: "configFetchedTimestamp", defaultValue: nil)
	public var configFetchedTimestamp: TimeInterval?

	@Shared.UserDefaults(key: "configFetchedHash", defaultValue: nil)
	public var configFetchedHash: String?

	@Shared.UserDefaults(key: "issuerKeysFetchedTimestamp", defaultValue: nil)
	public var issuerKeysFetchedTimestamp: TimeInterval?

	@Shared.UserDefaults(key: "lastScreenshotTime", defaultValue: nil)
	public var lastScreenshotTime: Date?

	@Shared.UserDefaults(key: "lastRecommendUpdateDismissalTimestamp", defaultValue: nil)
	public var lastRecommendUpdateDismissalTimestamp: TimeInterval?

	@Shared.UserDefaults(key: "lastSeenRecommendedUpdate", defaultValue: nil)
	public var lastSeenRecommendedUpdate: String?
	
	@Shared.UserDefaults(key: "lastSuccessfulCompletionOfAddCertificateFlowDate", defaultValue: nil)
	public var lastSuccessfulCompletionOfAddCertificateFlowDate: Date?

	@Shared.UserDefaults(key: "deviceAuthenticationWarningShown", defaultValue: false)
	public var deviceAuthenticationWarningShown: Bool
	
	@Shared.UserDefaults(key: "configVerificationPolicies")
	public var configVerificationPolicies: [VerificationPolicy] = []
	
	@Shared.UserDefaults(key: "policyInformationShown", defaultValue: false)
	public var policyInformationShown: Bool

	@Shared.UserDefaults(key: "hasDismissedZeroGPolicy") // special-case because `lastDismissedDisclosurePolicy` was released with `defaultValue: []`
	public var hasDismissedZeroGPolicy: Bool = false
	
	@Shared.UserDefaults(key: "overrideDisclosurePolicies")
	public var overrideDisclosurePolicies: [String] = []
	
	@Shared.UserDefaults(key: "lastKnownConfigDisclosurePolicy")
	public var lastKnownConfigDisclosurePolicy: [String] = ["3G"]
	
	// The alert which tells the user that one of their certificates has been blocked:
	@Shared.UserDefaults(key: "hasShownBlockedEventsAlert")
	public var hasShownBlockedEventsAlert: Bool = false
}

extension UserSettings {

	public func wipePersistedData() {
		
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
			"overrideDisclosurePolicies",
			"lastKnownConfigDisclosurePolicy",
			"hasDismissedZeroGPolicy",
			"hasShownBlockedEventsAlert",

			// Deprecated keys
			"lastDismissedDisclosurePolicy",
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
