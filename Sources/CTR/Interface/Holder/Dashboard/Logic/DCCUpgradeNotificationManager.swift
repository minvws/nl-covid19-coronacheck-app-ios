//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class DCCUpgradeNotificationManager {

	// Settable callbacks:
	var showUpgradeAvailableBanner: (() -> Void)?
	var showUpgradeCompletedBanner: (() -> Void)?

	private let userSettings: UserSettingsProtocol

	init(userSettings: UserSettingsProtocol) {
		self.userSettings = userSettings
	}

	func reload() {
		guard let showUpgradeAvailableBanner = showUpgradeAvailableBanner,
			  let showUpgradeCompletedBanner = showUpgradeCompletedBanner
		else { return }

		// If we already completed it, show the completed banner
		guard !userSettings.didCompleteEUVaccinationUpgrade else {
			if !userSettings.didDismissEUVaccinationUpgradeSuccessBanner {
				showUpgradeCompletedBanner()
			}
			return
		}

		guard !Services.walletManager.canSkipMultiDCCUpgrade() else {

			// next time skip check.
			userSettings.didCompleteEUVaccinationUpgrade = true
			userSettings.didDismissEUVaccinationUpgradeSuccessBanner = true

			// don't show banner
			return
		}

		if Services.walletManager.shouldShowMultiDCCUpgradeBanner(userSettings: userSettings) {

			showUpgradeAvailableBanner()
		}
	}
}
