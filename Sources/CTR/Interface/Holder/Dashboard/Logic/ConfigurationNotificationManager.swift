/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationNotificationManagerProtocol {

	func shouldShowAlmostOutOfDateBanner(now: Date, remoteConfiguration: RemoteConfiguration) -> Bool

	func getAlmostOutOfDateTimeStamp(remoteConfiguration: RemoteConfiguration) -> TimeInterval?
}

final class ConfigurationNotificationManager: ConfigurationNotificationManagerProtocol, Logging {

	private let userSettings: UserSettingsProtocol

	init(userSettings: UserSettingsProtocol) {
		self.userSettings = userSettings
	}

	func shouldShowAlmostOutOfDateBanner(now: Date, remoteConfiguration: RemoteConfiguration) -> Bool {

		logVerbose("ConfigurationNotificationManager Now: \(now)")
		guard let almostOutOfDateTimestamp = getAlmostOutOfDateTimeStamp(remoteConfiguration: remoteConfiguration) else {
			return false
		}
		// The config should be older the minimum config interval
		return almostOutOfDateTimestamp < now.timeIntervalSince1970
	}

	func getAlmostOutOfDateTimeStamp(remoteConfiguration: RemoteConfiguration) -> TimeInterval? {

		guard let configFetchedTimestamp = userSettings.configFetchedTimestamp,
			  let configAlmostOutOfDateWarningSeconds = remoteConfiguration.configAlmostOutOfDateWarningSeconds else {
			return nil
		}

		logVerbose("ConfigurationNotificationManager configFetchedTimestamp: \(Date(timeIntervalSince1970: configFetchedTimestamp))")
		logVerbose("ConfigurationNotificationManager configAlmostOutOfDateWarningSeconds: \(configAlmostOutOfDateWarningSeconds)")

		return configFetchedTimestamp + TimeInterval(configAlmostOutOfDateWarningSeconds)
	}

}
