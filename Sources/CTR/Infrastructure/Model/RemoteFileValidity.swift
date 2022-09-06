/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Transport

enum RemoteFileValidity {

	case neverFetched
	case withinTTL
	case withinMinimalInterval // should not refresh
	case refreshNeeded

	static func evaluateIfUpdateNeeded(
		configuration: RemoteConfiguration,
		lastFetchedTimestamp: TimeInterval?,
		isAppLaunching: Bool,
		now: @escaping () -> Date)
	-> RemoteFileValidity {

		guard let lastFetchedTimestamp = lastFetchedTimestamp else {
			return .neverFetched
		}
		
		guard lastFetchedTimestamp < now().timeIntervalSince1970 else {
			// prevent someone putting device way into the future to get a far-distant `lastFetchedTimestamp`
			// (which would prevent the config from being updated)
			return .refreshNeeded
		}

		let ttlThreshold = (now().timeIntervalSince1970 - TimeInterval(configuration.configTTL ?? 0))
		let fileValidity: RemoteFileValidity = lastFetchedTimestamp > ttlThreshold ? .withinTTL : .refreshNeeded

		guard let minimumRefreshIntervalValue = configuration.configMinimumIntervalSeconds
		else {
			return fileValidity
		}

		let minimumTimeAgoInterval = TimeInterval(minimumRefreshIntervalValue)
		let isWithinMinimumTimeInterval = lastFetchedTimestamp > (now().timeIntervalSince1970 - minimumTimeAgoInterval)

		// If isAppLaunching, skip minimumTimeInterval:
		guard !isWithinMinimumTimeInterval || (isWithinMinimumTimeInterval && isAppLaunching) else {
			// 🛑 device is still within the configMinimumIntervalSeconds, so prevent another refresh:
			return .withinMinimalInterval
		}
		return fileValidity
	}
}
