/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Environment {
	
	/// Reset all the data within applicable Services
	func wipePersistedData(flavor: AppFlavor) {
		
		appInstalledSinceManager.wipePersistedData()
		cryptoLibUtility.wipePersistedData()
		forcedInformationManager.wipePersistedData()
		onboardingManager.wipePersistedData()
		remoteConfigManager.wipePersistedData()
		userSettings.wipePersistedData()
		secureUserSettings.wipePersistedData()

		switch flavor {
			case .holder:
				walletManager.removeExistingEventGroups()
				walletManager.removeExistingGreenCards()
			case .verifier:
				riskLevelManager.wipePersistedData()
				scanLockManager.wipePersistedData()
				scanLogManager.wipePersistedData()
		}
		
		cryptoManager.generateSecretKey()
	}
}
