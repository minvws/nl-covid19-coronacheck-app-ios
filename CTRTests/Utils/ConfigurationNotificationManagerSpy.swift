/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class ConfigurationNotificationManagerSpy: ConfigurationNotificationManagerProtocol {

	var invokedShouldShowAlmostOutOfDateBanner = false
	var invokedShouldShowAlmostOutOfDateBannerCount = 0
	var invokedShouldShowAlmostOutOfDateBannerParameters: (now: Date, remoteConfiguration: RemoteConfiguration)?
	var invokedShouldShowAlmostOutOfDateBannerParametersList = [(now: Date, remoteConfiguration: RemoteConfiguration)]()
	var stubbedShouldShowAlmostOutOfDateBannerResult: Bool! = false

	func shouldShowAlmostOutOfDateBanner(now: Date, remoteConfiguration: RemoteConfiguration) -> Bool {
		invokedShouldShowAlmostOutOfDateBanner = true
		invokedShouldShowAlmostOutOfDateBannerCount += 1
		invokedShouldShowAlmostOutOfDateBannerParameters = (now, remoteConfiguration)
		invokedShouldShowAlmostOutOfDateBannerParametersList.append((now, remoteConfiguration))
		return stubbedShouldShowAlmostOutOfDateBannerResult
	}
}
