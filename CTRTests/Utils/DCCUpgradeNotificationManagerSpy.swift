/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class DCCMigrationNotificationManagerSpy: DCCMigrationNotificationManagerProtocol {

	var invokedShowMigrationAvailableBannerSetter = false
	var invokedShowMigrationAvailableBannerSetterCount = 0
	var invokedShowMigrationAvailableBanner: (() -> Void)?
	var invokedShowMigrationAvailableBannerList = [(() -> Void)?]()
	var invokedShowMigrationAvailableBannerGetter = false
	var invokedShowMigrationAvailableBannerGetterCount = 0
	var stubbedShowMigrationAvailableBanner: (() -> Void)!

	var showMigrationAvailableBanner: (() -> Void)? {
		set {
			invokedShowMigrationAvailableBannerSetter = true
			invokedShowMigrationAvailableBannerSetterCount += 1
			invokedShowMigrationAvailableBanner = newValue
			invokedShowMigrationAvailableBannerList.append(newValue)
		}
		get {
			invokedShowMigrationAvailableBannerGetter = true
			invokedShowMigrationAvailableBannerGetterCount += 1
			return stubbedShowMigrationAvailableBanner
		}
	}

	var invokedShowMigrationCompletedBannerSetter = false
	var invokedShowMigrationCompletedBannerSetterCount = 0
	var invokedShowMigrationCompletedBanner: (() -> Void)?
	var invokedShowMigrationCompletedBannerList = [(() -> Void)?]()
	var invokedShowMigrationCompletedBannerGetter = false
	var invokedShowMigrationCompletedBannerGetterCount = 0
	var stubbedShowMigrationCompletedBanner: (() -> Void)!

	var showMigrationCompletedBanner: (() -> Void)? {
		set {
			invokedShowMigrationCompletedBannerSetter = true
			invokedShowMigrationCompletedBannerSetterCount += 1
			invokedShowMigrationCompletedBanner = newValue
			invokedShowMigrationCompletedBannerList.append(newValue)
		}
		get {
			invokedShowMigrationCompletedBannerGetter = true
			invokedShowMigrationCompletedBannerGetterCount += 1
			return stubbedShowMigrationCompletedBanner
		}
	}

	var invokedReload = false
	var invokedReloadCount = 0

	func reload() {
		invokedReload = true
		invokedReloadCount += 1
	}
}
