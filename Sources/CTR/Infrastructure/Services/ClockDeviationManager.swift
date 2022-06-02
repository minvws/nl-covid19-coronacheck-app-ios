/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ClockDeviationManaging: AnyObject {
	var hasSignificantDeviation: Bool? { get }
	var observatory: Observatory<Bool> { get }

	func update(serverHeaderDate: String, ageHeader: String?)
	func update(serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t)
}

class ClockDeviationManager: ClockDeviationManaging, Logging {

	var hasSignificantDeviation: Bool? {
		guard let serverResponseDateTime = serverResponseDateTime,
			let localResponseDatetime = localResponseDateTime,
			let localResponseSystemUptime = localResponseSystemUptime,
			let clockDeviationThresholdSeconds = clockDeviationThresholdSeconds,
			let systemUptime = currentSystemUptime()
		else { return nil }

		let result = ClockDeviationManager.hasSignificantDeviation(
			serverResponseDateTime: serverResponseDateTime,
			localResponseDateTime: localResponseDatetime,
			localResponseSystemUptime: localResponseSystemUptime,
			currentDate: now(),
			currentSystemUptime: systemUptime,
			clockDeviationThresholdSeconds: clockDeviationThresholdSeconds
		)

		return result
	}

	// Mechanism for registering for external state change notifications:
	let observatory: Observatory<Bool>
	private let notifyObservers: (Bool) -> Void
	
	private var serverResponseDateTime: Date?
	private var localResponseDateTime: Date?
	private var localResponseSystemUptime: __darwin_time_t?

	private var clockDeviationThresholdSeconds: Double? {
		remoteConfigManager.storedConfiguration.clockDeviationThresholdSeconds.map { Double($0) }
	}
	private let remoteConfigManager: RemoteConfigManaging
	private let currentSystemUptime: () -> __darwin_time_t?
	private let now: () -> Date

	required init(
		remoteConfigManager: RemoteConfigManaging,
		currentSystemUptime: @escaping () -> __darwin_time_t? = { ClockDeviationManager.currentSystemUptime() },
		now: @escaping () -> Date
	) {
		self.remoteConfigManager = remoteConfigManager
		self.currentSystemUptime = currentSystemUptime
		self.now = now
		(self.observatory, self.notifyObservers) = Observatory<Bool>.create()
		
		NotificationCenter.default.addObserver(self, selector: #selector(systemClockDidChange), name: .NSSystemClockDidChange, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// NSSystemClockDidChangeNotification
	@objc func systemClockDidChange() {
		logDebug("📣 System clock did change")

		notifyObservers(hasSignificantDeviation ?? false)
	}

	/// Update using the Server Response Header string
	/// e.g. "Sat, 07 Aug 2021 12:12:57 GMT"
	func update(serverHeaderDate: String, ageHeader: String?) {
		guard var serverDate = DateFormatter.Header.serverDate.date(from: serverHeaderDate),
			  let systemUptime = currentSystemUptime()
		else { return }

		if let ageHeader = ageHeader {
			// CDN has a stale Date, but adds an Age field in seconds.
			let age = TimeInterval(ageHeader) ?? 0
			logVerbose("Added \(age) seconds to stale CDN date \(serverDate)")
			serverDate = serverDate.addingTimeInterval(age)
		}

		update(
			serverResponseDateTime: serverDate,
			localResponseDateTime: now(),
			localResponseSystemUptime: systemUptime
		)
	}

	func update(serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t) {
		self.serverResponseDateTime = serverResponseDateTime
		self.localResponseDateTime = localResponseDateTime
		self.localResponseSystemUptime = localResponseSystemUptime
		notifyObservers(hasSignificantDeviation ?? false)
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
		localResponseDateTime: Date,
		localResponseSystemUptime: __darwin_time_t,
		currentDate: Date = Date(),
		currentSystemUptime: __darwin_time_t,
		clockDeviationThresholdSeconds: Double
	) -> Bool {

		let responseSystemStartDatetime = localResponseDateTime.timeIntervalSince1970 - TimeInterval(localResponseSystemUptime)
		let currentSystemStartDateTime = currentDate.timeIntervalSince1970 - TimeInterval(currentSystemUptime)
		let systemUptimeDelta = currentSystemStartDateTime - responseSystemStartDatetime
		let responseTimeDelta = localResponseDateTime.timeIntervalSince1970 - serverResponseDateTime.timeIntervalSince1970

		let hasDeviation = abs(responseTimeDelta + systemUptimeDelta) >= clockDeviationThresholdSeconds
		return hasDeviation
	}

	static func currentSystemUptime() -> __darwin_time_t? {

		var uptime = timespec()

		// `CLOCK_MONOTONIC` represents the absolute elapsed wall-clock time since some arbitrary,
		// fixed point in the past. It isn't affected by changes in the system time-of-day clock.

		// Check response is 0 else there was an error:
		guard clock_gettime(CLOCK_MONOTONIC, &uptime) == 0 else {
			return nil
		}

		return uptime.tv_sec
	}
}
