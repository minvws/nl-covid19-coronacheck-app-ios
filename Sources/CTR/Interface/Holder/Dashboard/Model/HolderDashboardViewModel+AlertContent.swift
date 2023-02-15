/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import ReusableViews
import Resources

extension AlertContent {

	static func strippenExpiredWithNoInternet(strippenRefresher: DashboardStrippenRefreshing) -> AlertContent {
		
		return strippenExpiredWithNoInternet(
			title: L.holderDashboardStrippenExpiredNointernetAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiredNointernetAlertMessage(),
			strippenRefresher: strippenRefresher
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
		
		return strippenExpiredWithNoInternet(
			title: L.holderDashboardStrippenExpiringNointernetAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiringNointernetAlertMessage(localizedTimeRemainingUntilExpiry),
			strippenRefresher: strippenRefresher
		)
	}
	
	static func strippenExpiredWithNoInternet(
		title: String,
		subTitle: String,
		strippenRefresher: DashboardStrippenRefreshing) -> AlertContent {
		AlertContent(
			title: title,
			subTitle: subTitle,
			okAction: AlertContent.Action(
				title: L.generalRetry(),
				action: { _ in
					strippenRefresher.load()
				}
			),
			cancelAction: AlertContent.Action(
				title: L.generalClose(),
				action: { _ in
					strippenRefresher.userDismissedALoadingError()
				}
			)
		)
	}
}
