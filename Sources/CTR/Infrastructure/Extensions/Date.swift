/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Date {

	/// to be used like `now.isWithinTimeWindow(.originValidFrom, origin.expireTime)`
	func isWithinTimeWindow(from: Date, to: Date) -> Bool {
		guard from <= to else { return false } // otherwise it can crash
		return (from...to).contains(self)
	}
}
