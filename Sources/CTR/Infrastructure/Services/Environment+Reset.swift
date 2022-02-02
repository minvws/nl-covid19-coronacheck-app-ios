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
		newFeaturesManager.wipePersistedData()
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
	
	/// Reset verifier scan mode, including risk setting, scan lock and scan log
	func wipeScanMode() {
		// Scan lock and risk level observers are not wiped
		// in case this method is called after setting the observers in VerifierStartScanningViewModel
		riskLevelManager.wipeScanMode()
		scanLockManager.wipeScanMode()
		scanLogManager.wipePersistedData()
	}
}
