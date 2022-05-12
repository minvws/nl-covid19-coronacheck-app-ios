/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension TimeInterval {

	private var minutes: Int {

		return (Int(self) / 60 ) % 60
	}

	private var hours: Int {

		return Int(self) / 3600
	}

	var stringTime: String {
		let localizedHour = L.holderDashboardQrHour()
		let localizedMinute = L.holderDashboardQrMinute()

		if hours != 0 {
			return "\(hours) \(localizedHour) \(minutes) \(localizedMinute)"
		} else if minutes != 0 {
			return "\(minutes) \(localizedMinute)"
		} else {
			return  "1 \(localizedMinute)"
		}
	}

	var accessibilityTime: String {
		let localizedHour = L.holderDashboardQrHour()
		let localizedMinute = L.holderDashboardQrMinute()
		let localizedMinutes = L.holderDashboardQrMinutesLong()

		if hours != 0 {
			if minutes > 1 {
				return "\(hours) \(localizedHour) \(minutes) \(localizedMinutes)"
			} else if minutes == 0 {
				return "\(hours) \(localizedHour)"
			} else {
				return "\(hours) \(localizedHour) \(minutes) \(localizedMinute)"
			}
		} else if minutes != 0 {
			if minutes > 1 {
				return "\(minutes) \(localizedMinutes)"
			} else {
				return "\(minutes) \(localizedMinute)"
			}
		} else {
			return  "1 \(localizedMinute)"
		}
	}
}
