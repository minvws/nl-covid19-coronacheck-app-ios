/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension AlertContent {

	static func strippenExpiredWithNoInternet(strippenRefresher: DashboardStrippenRefreshing) -> AlertContent {
		AlertContent(
			title: L.holderDashboardStrippenExpiredNointernetAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiredNointernetAlertMessage(),
			cancelAction: { _ in
				strippenRefresher.userDismissedALoadingError()
			},
			cancelTitle: L.generalClose(),
			okAction: { _ in
				strippenRefresher.load()
			},
			okTitle: L.generalRetry()
		)
	}

	static func strippenExpiringWithNoInternet(expiryDate: Date, strippenRefresher: DashboardStrippenRefreshing, now: Date) -> AlertContent {

		let localizedTimeRemainingUntilExpiry: String = {
			if expiryDate > (now.addingTimeInterval(60 * 60 * 24)) { // > 1 day in future
				return DateFormatter.Relative.days.string(from: now, to: expiryDate) ?? "-"
			} else {
				return DateFormatter.Relative.hoursMinutes.string(from: now, to: expiryDate) ?? "-"
			}
		}()

		return AlertContent(
			title: L.holderDashboardStrippenExpiringNointernetAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiringNointernetAlertMessage(localizedTimeRemainingUntilExpiry),
			cancelAction: { _ in
				strippenRefresher.userDismissedALoadingError()
			},
			cancelTitle: L.generalClose(),
			okAction: { _ in
				strippenRefresher.load()
			},
			okTitle: L.generalRetry()
		)
	}
}
