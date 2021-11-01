/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum RemoteFileValidity {

	case neverFetched
	case withinTTL
	case withinMinimalInterval // should not refresh
	case refreshNeeded

	static func evaluateIfUpdateNeeded(
		configuration: RemoteConfiguration,
		lastFetchedTimestamp: TimeInterval?,
		isAppFirstLaunch: Bool,
		now: @escaping () -> Date)
	-> RemoteFileValidity {

		guard let lastFetchedTimestamp = lastFetchedTimestamp else {
			return .neverFetched
		}

		let ttlThreshold = (now().timeIntervalSince1970 - TimeInterval(configuration.configTTL ?? 0))
		let fileValidity: RemoteFileValidity = lastFetchedTimestamp > ttlThreshold ? .withinTTL : .refreshNeeded

		guard let minimumRefreshIntervalValue = configuration.configMinimumIntervalSeconds
		else {
			return fileValidity
		}

		let minimumTimeAgoInterval = TimeInterval(minimumRefreshIntervalValue)
		let isWithinMinimumTimeInterval = lastFetchedTimestamp > (now().timeIntervalSince1970 - minimumTimeAgoInterval)

		// If isAppFirstLaunch, skip minimumTimeInterval:
		guard !isWithinMinimumTimeInterval || (isWithinMinimumTimeInterval && isAppFirstLaunch) else {
			// 🛑 device is still within the configMinimumIntervalSeconds, so prevent another refresh:
			return .withinMinimalInterval
		}
		return fileValidity
	}
}
