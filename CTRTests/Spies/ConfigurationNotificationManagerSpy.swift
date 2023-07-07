/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
@testable import CTR

class ConfigurationNotificationManagerSpy: ConfigurationNotificationManagerProtocol {

	var invokedShouldShowAlmostOutOfDateBannerGetter = false
	var invokedShouldShowAlmostOutOfDateBannerGetterCount = 0
	var stubbedShouldShowAlmostOutOfDateBanner: Bool! = false

	var shouldShowAlmostOutOfDateBanner: Bool {
		invokedShouldShowAlmostOutOfDateBannerGetter = true
		invokedShouldShowAlmostOutOfDateBannerGetterCount += 1
		return stubbedShouldShowAlmostOutOfDateBanner
	}

	var invokedAlmostOutOfDateObservatoryGetter = false
	var invokedAlmostOutOfDateObservatoryGetterCount = 0
	var stubbedAlmostOutOfDateObservatory: Observatory<Bool>!

	var almostOutOfDateObservatory: Observatory<Bool> {
		invokedAlmostOutOfDateObservatoryGetter = true
		invokedAlmostOutOfDateObservatoryGetterCount += 1
		return stubbedAlmostOutOfDateObservatory
	}
}
