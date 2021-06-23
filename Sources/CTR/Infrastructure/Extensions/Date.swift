//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Date {

	/// Return date at second of source date
	var timeAtMidnight: Date {
		let cal = NSCalendar(calendarIdentifier: .gregorian)!
		let components = cal.components([.day, .month, .year], from: self)
		return cal.date(from: components)!
	}
}
