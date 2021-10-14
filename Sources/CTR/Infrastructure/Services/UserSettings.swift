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

	var lastScreenshotTime: Date? { get set }

	var issuerKeysFetchedTimestamp: TimeInterval? { get set }

	var lastRecommendUpdateDismissalTimestamp: TimeInterval? { get set }

	var deviceAuthenticationWarningShown: Bool { get set }

	// Flags for upgrading to Multiple DCCs:
	var didCompleteEUVaccinationMigration: Bool { get set }
	var didDismissEUVaccinationMigrationSuccessBanner: Bool { get set }

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

	@UserDefaults(key: "issuerKeysFetchedTimestamp", defaultValue: nil)
	var issuerKeysFetchedTimestamp: TimeInterval? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "lastScreenshotTime", defaultValue: nil)
	var lastScreenshotTime: Date? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "lastRecommendUpdateDismissalTimestamp", defaultValue: nil)
	var lastRecommendUpdateDismissalTimestamp: TimeInterval? // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "deviceAuthenticationWarningShown", defaultValue: false)
	var deviceAuthenticationWarningShown: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "didCompleteEUVaccinationMigration", defaultValue: false)
	var didCompleteEUVaccinationMigration: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "didDismissEUVaccinationMigrationSuccessBanner", defaultValue: false)
	var didDismissEUVaccinationMigrationSuccessBanner: Bool // swiftlint:disable:this let_var_whitespace

	func reset() {
		// Clear user defaults:
		let userDefaults = Foundation.UserDefaults.standard

		userDefaults
			.dictionaryRepresentation()
			.keys
			.forEach(userDefaults.removeObject(forKey:))
	}
}
