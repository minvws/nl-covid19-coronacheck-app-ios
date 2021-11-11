/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import CoreData

class RecoveryValidityExtensionManagerSpy: RecoveryValidityExtensionManagerProtocol {

	var invokedBannerStateCallbackSetter = false
	var invokedBannerStateCallbackSetterCount = 0
	var invokedBannerStateCallback: ((BannerType?) -> Void)?
	var invokedBannerStateCallbackList = [((BannerType?) -> Void)?]()
	var invokedBannerStateCallbackGetter = false
	var invokedBannerStateCallbackGetterCount = 0
	var stubbedBannerStateCallback: ((BannerType?) -> Void)!

	var bannerStateCallback: ((BannerType?) -> Void)? {
		set {
			invokedBannerStateCallbackSetter = true
			invokedBannerStateCallbackSetterCount += 1
			invokedBannerStateCallback = newValue
			invokedBannerStateCallbackList.append(newValue)
		}
		get {
			invokedBannerStateCallbackGetter = true
			invokedBannerStateCallbackGetterCount += 1
			return stubbedBannerStateCallback
		}
	}

	var invokedReload = false
	var invokedReloadCount = 0

	func reload() {
		invokedReload = true
		invokedReloadCount += 1
	}
}
