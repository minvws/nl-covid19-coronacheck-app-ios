/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationNotificationManagerProtocol {

	func shouldShowAlmostOutOfDateBanner(now: Date, remoteConfiguration: RemoteConfiguration) -> Bool
}

final class ConfigurationNotificationManager: ConfigurationNotificationManagerProtocol, Logging {

	private let userSettings: UserSettingsProtocol

	init(userSettings: UserSettingsProtocol) {
		self.userSettings = userSettings
	}

	func shouldShowAlmostOutOfDateBanner(now: Date, remoteConfiguration: RemoteConfiguration) -> Bool {

		guard let configFetchedTimestamp = userSettings.configFetchedTimestamp,
			  let configAlmostOutOfDateWarningSeconds = remoteConfiguration.configAlmostOutOfDateWarningSeconds else {
			return false
		}

		logDebug("ConfigurationNotificationManager Now: \(now)")
		logDebug("ConfigurationNotificationManager configFetchedTimestamp: \(Date(timeIntervalSince1970: configFetchedTimestamp))")
		logDebug("ConfigurationNotificationManager configAlmostOutOfDateWarningSeconds: \(configAlmostOutOfDateWarningSeconds)")

		// The config should be older the minimum config interval
		return configFetchedTimestamp + TimeInterval(configAlmostOutOfDateWarningSeconds) < now.timeIntervalSince1970
	}
}
