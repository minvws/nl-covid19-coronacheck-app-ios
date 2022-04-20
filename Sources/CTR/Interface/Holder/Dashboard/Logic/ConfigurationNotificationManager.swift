/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ConfigurationNotificationManagerProtocol {
	var shouldShowAlmostOutOfDateBanner: Bool { get }
	var almostOutOfDateObservatory: Observatory<Bool> { get }
}

final class ConfigurationNotificationManager: ConfigurationNotificationManagerProtocol, Logging {

	private let userSettings: UserSettingsProtocol
	private let remoteConfigManager: RemoteConfigManaging
	private let now: () -> Date
	private let notificationCenter: NotificationCenterProtocol
	private var timer: Timeable?
	
	// "vends" a timer from the closure
	private let vendTimer: (TimeInterval, @escaping () -> Void) -> Timeable
	private var callback: (() -> Void)?
	private var remoteConfigManagerReloadObserverToken: UUID?
	
	// Mechanism for registering for external state change notifications:
	let almostOutOfDateObservatory: Observatory<Bool>
	private let almostOutOfDateNotifyObservers: (Bool) -> Void
	
	var shouldShowAlmostOutOfDateBanner: Bool {
		guard let configBecomesAlmostOutOfDateAt = configBecomesAlmostOutOfDateAt else { return false }
		return configBecomesAlmostOutOfDateAt < now()
	}
	
	private var timeBeforeConfigAlmostOutOfDateWarning: TimeInterval? {
		guard let configBecomesAlmostOutOfDateAt = configBecomesAlmostOutOfDateAt else { return nil }
		let timeBeforeConfigAlmostOutOfDateWarning = configBecomesAlmostOutOfDateAt.timeIntervalSince1970 - now().timeIntervalSince1970
		return timeBeforeConfigAlmostOutOfDateWarning
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

	init(
		userSettings: UserSettingsProtocol,
		remoteConfigManager: RemoteConfigManaging,
		now: @escaping () -> Date,
		notificationCenter: NotificationCenterProtocol = NotificationCenter.default,
		vendTimer: @escaping (TimeInterval, @escaping () -> Void) -> Timeable = { interval, action in
			return Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in action() }
		}
	) {
		self.userSettings = userSettings
		self.remoteConfigManager = remoteConfigManager
		self.now = now
		self.notificationCenter = notificationCenter
		self.vendTimer = vendTimer
		(self.almostOutOfDateObservatory, self.almostOutOfDateNotifyObservers) = Observatory<Bool>.create()
		
		setupNotificationCenterObservation()
		restartTimer()
		
		remoteConfigManagerReloadObserverToken = remoteConfigManager.observatoryForReloads.append { [weak self] _ in
			guard let self = self else { return }
			self.almostOutOfDateNotifyObservers(self.shouldShowAlmostOutOfDateBanner)
			self.restartTimer()
		}
	}

	deinit {
		stopTimer()
		remoteConfigManagerReloadObserverToken.map { remoteConfigManager.observatoryForReloads.remove(observerToken: $0) }
	}

	private func setupNotificationCenterObservation() {
		notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			// Timers aren't reliable in the background. Just remove it, we'll re-add it if/when we return:
			self?.stopTimer()
		}
		notificationCenter.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
			guard let self = self else { return }
			if let timeBeforeConfigAlmostOutOfDateWarning = self.timeBeforeConfigAlmostOutOfDateWarning, timeBeforeConfigAlmostOutOfDateWarning <= 0 {
				// time's up:
				self.almostOutOfDateNotifyObservers(self.shouldShowAlmostOutOfDateBanner)
			} else {
				self.restartTimer()
			}
		}
	}
	
	private func restartTimer() {
		guard let timeBeforeConfigAlmostOutOfDateWarning = self.timeBeforeConfigAlmostOutOfDateWarning else { return }

		stopTimer()
		
		timer = vendTimer(timeBeforeConfigAlmostOutOfDateWarning) { [weak self] in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				self.almostOutOfDateNotifyObservers(self.shouldShowAlmostOutOfDateBanner)
				self.stopTimer()
			}
		}
	}

	func stopTimer() {
		
		timer?.invalidate()
		timer = nil
	}
}
