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
		guard let configBecomesAlmostOutOfDateAt = configBecomesAlmostOutOfDateAt else { return false }
		return configBecomesAlmostOutOfDateAt < now()
	}

	private var configBecomesAlmostOutOfDateAt: Date? {

		guard let configFetchedTimestamp = userSettings.configFetchedTimestamp,
			  let configTTLSeconds = remoteConfigManager.storedConfiguration.configTTL,
			  let configAlmostOutOfDateWarningSeconds = remoteConfigManager.storedConfiguration.configAlmostOutOfDateWarningSeconds
		else {
			return nil
		}

		let configFetchedDate = Date(timeIntervalSince1970: configFetchedTimestamp)
		
		guard let configExpiryDate = Calendar.current.date(byAdding: .second, value: configTTLSeconds, to: configFetchedDate),
			  let configAlmostExpiredDate = Calendar.current.date(byAdding: .second, value: -1 * configAlmostOutOfDateWarningSeconds, to: configExpiryDate)
		else {
			return nil
		}
		
		return configAlmostExpiredDate
	}

	func registerForAlmostOutOfDateUpdate(callback: @escaping () -> Void) {

		timer?.invalidate()
		
		guard let configBecomesAlmostOutOfDateAt = configBecomesAlmostOutOfDateAt else { return }

		let timeBeforeConfigAlmostOutOfDateWarning = configBecomesAlmostOutOfDateAt.timeIntervalSince1970 - now().timeIntervalSince1970
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
