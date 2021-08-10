/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ClockDeviationManaging: AnyObject {
	var hasSignificantDeviation: Bool? { get }

	init()

	func update(serverHeaderDate: String)
	func update(serverResponseDateTime: Date, localResponseDatetime: Date, localResponseSystemUptime: TimeInterval)

	func appendDeviationChangeObserver(_ observer: @escaping (Bool) -> Void) -> ClockDeviationManager.ObserverToken
	func removeDeviationChangeObserver(token: ClockDeviationManager.ObserverToken)
}

class ClockDeviationManager: ClockDeviationManaging, Logging {
	typealias ObserverToken = UUID

	var hasSignificantDeviation: Bool? {
		guard let serverResponseDateTime = serverResponseDateTime,
			let localResponseDatetime = localResponseDatetime,
			let localResponseSystemUptime = localResponseSystemUptime,
			let clockDeviationThresholdSeconds = clockDeviationThresholdSeconds
		else { return nil }

		let result = ClockDeviationManager.hasSignificantDeviation(
			serverResponseDateTime: serverResponseDateTime,
			localResponseDatetime: localResponseDatetime,
			clockDeviationThresholdSeconds: clockDeviationThresholdSeconds,
			localSystemUptime: localResponseSystemUptime,
			systemUptime: currentSystemUptime(),
			now: now()
		)
		return result
	}

	private var serverResponseDateTime: Date?
	private var localResponseDatetime: Date?
	private var localResponseSystemUptime: TimeInterval?

	private var clockDeviationThresholdSeconds: Double? {
		remoteConfigManager.getConfiguration().clockDeviationThresholdSeconds.map { Double($0) }
	}
	private let remoteConfigManager: RemoteConfigManaging
	private let currentSystemUptime: () -> TimeInterval
	private let now: () -> Date
	private var deviationChangeObservers = [ObserverToken: (Bool) -> Void]()
	private lazy var serverHeaderDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_GB") // because the server date contains day name
		dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
		return dateFormatter
	}()

	required convenience init() {
		self.init(
			remoteConfigManager: Services.remoteConfigManager,
			currentSystemUptime: { ProcessInfo.processInfo.systemUptime },
			now: { Date() }
		)
	}

	required init(
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager,
		currentSystemUptime: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime },
		now: @escaping () -> Date = { Date() }
	) {
		self.remoteConfigManager = remoteConfigManager
		self.currentSystemUptime = currentSystemUptime
		self.now = now

		NotificationCenter.default.addObserver(self, selector: #selector(systemClockDidChange), name: .NSSystemClockDidChange, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// NSSystemClockDidChangeNotification
	@objc func systemClockDidChange() {
		logDebug("📣 System clock did change")

		notifyObservers()
	}

	/// Update using the Server Response Header string
	/// e.g. "Sat, 07 Aug 2021 12:12:57 GMT"
	func update(serverHeaderDate: String) {
		guard let serverDate = serverHeaderDateFormatter.date(from: serverHeaderDate) else { return }

		update(
			serverResponseDateTime: serverDate,
			localResponseDatetime: now(),
			localResponseSystemUptime: currentSystemUptime()
		)
	}

	func update(serverResponseDateTime: Date, localResponseDatetime: Date, localResponseSystemUptime: TimeInterval) {
		self.serverResponseDateTime = serverResponseDateTime
		self.localResponseDatetime = localResponseDatetime
		self.localResponseSystemUptime = localResponseSystemUptime
		notifyObservers()
	}

	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func appendDeviationChangeObserver(_ observer: @escaping (Bool) -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		deviationChangeObservers[newToken] = observer
		return newToken
	}

	func removeDeviationChangeObserver(token: ObserverToken) {
		deviationChangeObservers[token] = nil
	}

	private func notifyObservers() {
		guard let hasDeviation = self.hasSignificantDeviation else { return }

		deviationChangeObservers.values.forEach { callback in
			callback(hasDeviation)
		}
	}

	/// Does the server time have a significant deviation from the local time?
	///   - Parameters:
	///		- serverResponseDateTime: the parsed datetime of the server Date header
	///		- localResponseDatetime: the local time at the time of receiving the response,
	///		- clockDeviationThresholdSeconds: the configuration value of how large a delta is allowed
	/// 	- localSystemUptime: the system uptime in (milli)seconds at the time of receiving the response.
	/// 	- systemUptime: current system uptime
	/// 	- now: the current local time
	private static func hasSignificantDeviation(
		serverResponseDateTime: Date,
		localResponseDatetime: Date,
		clockDeviationThresholdSeconds: Double,
		localSystemUptime: TimeInterval,
		systemUptime: TimeInterval,
		now: Date = Date()
	) -> Bool {

		let responseSystemStartDatetime = localResponseDatetime.timeIntervalSince1970 - localSystemUptime
		let currentSystemStartDateTime = now.timeIntervalSince1970 - systemUptime
		let systemUptimeDelta = currentSystemStartDateTime - responseSystemStartDatetime
		let responseTimeDelta = localResponseDatetime.timeIntervalSince1970 - serverResponseDateTime.timeIntervalSince1970

		let hasDeviation = abs(responseTimeDelta + systemUptimeDelta) >= clockDeviationThresholdSeconds
		return hasDeviation
	}
}
