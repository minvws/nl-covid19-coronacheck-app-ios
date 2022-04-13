/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationNotificationManagerProtocol {

	var shouldShowAlmostOutOfDateBanner: Bool { get }
	
	func registerForAlmostOutOfDateUpdate(callback: @escaping () -> Void)
}

final class ConfigurationNotificationManager: ConfigurationNotificationManagerProtocol, Logging {

	private let userSettings: UserSettingsProtocol
	private let remoteConfigManager: RemoteConfigManaging
	private let now: () -> Date
	private var timer: Timer?
	private var callback: (() -> Void)?

	init(userSettings: UserSettingsProtocol, remoteConfigManager: RemoteConfigManaging, now: @escaping () -> Date) {
		self.userSettings = userSettings
		self.remoteConfigManager = remoteConfigManager
		self.now = now
	}

	deinit {
		stopTimer()
	}

	var shouldShowAlmostOutOfDateBanner: Bool {

		logVerbose("ConfigurationNotificationManager Now: \(now())")
		guard let almostOutOfDateTimestamp = almostOutOfDateTimeStamp else { return false }
		
		// The config should be older the minimum config interval
		return almostOutOfDateTimestamp < now().timeIntervalSince1970
	}

	private var almostOutOfDateTimeStamp: TimeInterval? {

		guard let configFetchedTimestamp = userSettings.configFetchedTimestamp,
			  let configAlmostOutOfDateWarningSeconds = remoteConfigManager.storedConfiguration.configAlmostOutOfDateWarningSeconds else {
				  return nil
			  }

		logVerbose("ConfigurationNotificationManager configFetchedTimestamp: \(Date(timeIntervalSince1970: configFetchedTimestamp))")
		logVerbose("ConfigurationNotificationManager configAlmostOutOfDateWarningSeconds: \(configAlmostOutOfDateWarningSeconds)")

		return configFetchedTimestamp + TimeInterval(configAlmostOutOfDateWarningSeconds)
	}

	func registerForAlmostOutOfDateUpdate(callback: @escaping () -> Void) {

		timer?.invalidate()
		
		guard let almostOutOfDateTimestamp = almostOutOfDateTimeStamp else { return }

		let timeBeforeConfigAlmostOutOfDateWarning = almostOutOfDateTimestamp - now().timeIntervalSince1970
		logVerbose("Starting a timer with \(timeBeforeConfigAlmostOutOfDateWarning) seconds before the config is almost out of date")

		guard timeBeforeConfigAlmostOutOfDateWarning > 0 else {
			return
		}

		timer = Timer.scheduledTimer(withTimeInterval: timeBeforeConfigAlmostOutOfDateWarning, repeats: false) { [weak self] _ in

			DispatchQueue.main.async {
				callback()
				self?.stopTimer()
			}
		}
	}

	func stopTimer() {
		
		timer?.invalidate()
		timer = nil
	}
}
