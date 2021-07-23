/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Date {

	/// Return date one second before midnight for source date
	var oneSecondBeforeMidnight: Date? {
		let startOfDay = Calendar.current.startOfDay(for: self)
		var components = DateComponents()
		components.hour = 23
		components.minute = 59
		components.second = 59
		let endOfDay = Calendar.current.date(byAdding: components, to: startOfDay)
		return endOfDay
	}

	/// to be used like `now.isWithinTimeWindow(.originValidFrom, origin.expireTime)`
	func isWithinTimeWindow(from: Date, to: Date) -> Bool {
		guard from <= to else { return false } // otherwise it can crash
		return (from...to).contains(self)
	}
}
