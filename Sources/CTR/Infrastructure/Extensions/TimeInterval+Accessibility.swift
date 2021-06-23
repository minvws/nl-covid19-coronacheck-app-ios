/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

		if hours != 0 {
			return "\(hours) \(String.hour) \(minutes) \(String.minute)"
		} else if minutes != 0 {
			return "\(minutes) \(String.minute)"
		} else {
			return  "1 \(String.minute)"
		}
	}

	var accessibilityTime: String {

		if hours != 0 {
			if minutes > 1 {
				return "\(hours) \(String.hour) \(minutes) \(String.longMinutes)"
			} else if minutes == 0 {
				return "\(hours) \(String.hour)"
			} else {
				return "\(hours) \(String.hour) \(minutes) \(String.longMinute)"
			}
		} else if minutes != 0 {
			if minutes > 1 {
				return "\(minutes) \(String.longMinutes)"
			} else {
				return "\(minutes) \(String.longMinute)"
			}
		} else {
			return  "1 \(String.longMinute)"
		}
	}
}
