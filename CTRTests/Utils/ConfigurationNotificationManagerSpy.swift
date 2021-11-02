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

	var invokedGetAlmostOutOfDateTimeStamp = false
	var invokedGetAlmostOutOfDateTimeStampCount = 0
	var invokedGetAlmostOutOfDateTimeStampParameters: (remoteConfiguration: RemoteConfiguration, Void)?
	var invokedGetAlmostOutOfDateTimeStampParametersList = [(remoteConfiguration: RemoteConfiguration, Void)]()
	var stubbedGetAlmostOutOfDateTimeStampResult: TimeInterval!

	func getAlmostOutOfDateTimeStamp(remoteConfiguration: RemoteConfiguration) -> TimeInterval? {
		invokedGetAlmostOutOfDateTimeStamp = true
		invokedGetAlmostOutOfDateTimeStampCount += 1
		invokedGetAlmostOutOfDateTimeStampParameters = (remoteConfiguration, ())
		invokedGetAlmostOutOfDateTimeStampParametersList.append((remoteConfiguration, ()))
		return stubbedGetAlmostOutOfDateTimeStampResult
	}

	var invokedRegisterForAlmostOutOfDateUpdate = false
	var invokedRegisterForAlmostOutOfDateUpdateCount = 0
	var invokedRegisterForAlmostOutOfDateUpdateParameters: (now: Date, remoteConfiguration: RemoteConfiguration)?
	var invokedRegisterForAlmostOutOfDateUpdateParametersList = [(now: Date, remoteConfiguration: RemoteConfiguration)]()
	var shouldInvokeRegisterForAlmostOutOfDateUpdateCallback = false

	func registerForAlmostOutOfDateUpdate(now: Date, remoteConfiguration: RemoteConfiguration, callback: (() -> Void)?) {
		invokedRegisterForAlmostOutOfDateUpdate = true
		invokedRegisterForAlmostOutOfDateUpdateCount += 1
		invokedRegisterForAlmostOutOfDateUpdateParameters = (now, remoteConfiguration)
		invokedRegisterForAlmostOutOfDateUpdateParametersList.append((now, remoteConfiguration))
		if shouldInvokeRegisterForAlmostOutOfDateUpdateCallback {
			callback?()
		}
	}
}
