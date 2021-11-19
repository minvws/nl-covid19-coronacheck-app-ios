/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	var deviceAuthenticationWarningShown: Bool { get set }
	
	var scanRiskLevelValue: RiskLevel { get set }

	// Flags for upgrading to Multiple DCCs:
	var didCompleteEUVaccinationMigration: Bool { get set }
	var didDismissEUVaccinationMigrationSuccessBanner: Bool { get set }

	// Flags for extension of Recovery validity:
	var shouldCheckRecoveryGreenCardRevisedValidity: Bool { get set }
	var shouldShowRecoveryValidityExtensionCard: Bool { get set }
	var shouldShowRecoveryValidityReinstationCard: Bool { get set }
	var hasDismissedRecoveryValidityExtensionCompletionCard: Bool { get set }
	var hasDismissedRecoveryValidityReinstationCompletionCard: Bool { get set }
	
	func reset()
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

	@UserDefaults(key: "deviceAuthenticationWarningShown", defaultValue: false)
	var deviceAuthenticationWarningShown: Bool // swiftlint:disable:this let_var_whitespace
	
	@UserDefaults(key: "scanRiskLevelValue")
	var scanRiskLevelValue: RiskLevel = .low // swiftlint:disable:this let_var_whitespace

	// MARK: - Multiple DCC migration:

	@UserDefaults(key: "didCompleteEUVaccinationMigration", defaultValue: false)
	var didCompleteEUVaccinationMigration: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "didDismissEUVaccinationMigrationSuccessBanner", defaultValue: false)
	var didDismissEUVaccinationMigrationSuccessBanner: Bool // swiftlint:disable:this let_var_whitespace

	// MARK: - Extension of Recovery validity:

	@UserDefaults(key: "shouldCheckRecoveryGreenCardRevisedValidity", defaultValue: true)
	var shouldCheckRecoveryGreenCardRevisedValidity: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "shouldShowRecoveryValidityExtensionCard", defaultValue: false)
	var shouldShowRecoveryValidityExtensionCard: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "shouldShowRecoveryValidityReinstationCard", defaultValue: false)
	var shouldShowRecoveryValidityReinstationCard: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "hasDismissedRecoveryValidityExtensionCompletionCard", defaultValue: true)
	var hasDismissedRecoveryValidityExtensionCompletionCard: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "hasDismissedRecoveryValidityReinstationCompletionCard", defaultValue: true)
	var hasDismissedRecoveryValidityReinstationCompletionCard: Bool // swiftlint:disable:this let_var_whitespace
}

extension UserSettings {

	func reset() {
		// Clear user defaults:
		// We can not simply loop over all the keys, as some are needed for clear on reinstall for the keychain items.
		let userDefaults = Foundation.UserDefaults.standard
		["scanInstructionShown", "jailbreakWarningShown", "dashboardRegionToggleValue", "configFetchedTimestamp", "configFetchedHash",
		"issuerKeysFetchedTimestamp", "lastScreenshotTime", "lastRecommendUpdateDismissalTimestamp", "deviceAuthenticationWarningShown",
		 "scanRiskSettingValue", "didCompleteEUVaccinationMigration", "didDismissEUVaccinationMigrationSuccessBanner",
		 "shouldCheckRecoveryGreenCardRevisedValidity", "shouldShowRecoveryValidityExtensionCard",
		 "shouldShowRecoveryValidityReinstationCard", "hasDismissedRecoveryValidityExtensionCompletionCard",
		 "hasDismissedRecoveryValidityReinstationCompletionCard"]
			.forEach(userDefaults.removeObject(forKey:))
	}
}
