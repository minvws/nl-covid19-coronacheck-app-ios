/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class DCCMigrationNotificationManager {

	// Callbacks:
	var showMigrationAvailableBanner: (() -> Void)?
	var showMigrationCompletedBanner: (() -> Void)?

	private let userSettings: UserSettingsProtocol

	init(userSettings: UserSettingsProtocol) {
		self.userSettings = userSettings
	}

	func reload() {
		guard let showUpgradeAvailableBanner = showMigrationAvailableBanner,
			  let showUpgradeCompletedBanner = showMigrationCompletedBanner
		else { return }

		// If we already completed it, show the completed banner
		guard !userSettings.didCompleteEUVaccinationMigration else {
			if !userSettings.didDismissEUVaccinationMigrationSuccessBanner {
				showUpgradeCompletedBanner()
			}
			return
		}

		guard !Services.walletManager.canSkipMultiDCCUpgrade() else {

			// next time skip check.
			userSettings.didCompleteEUVaccinationMigration = true
			userSettings.didDismissEUVaccinationMigrationSuccessBanner = true

			// don't show banner
			return
		}

		if Services.walletManager.shouldShowMultiDCCUpgradeBanner(userSettings: userSettings) {

			showUpgradeAvailableBanner()
		}
	}
}
