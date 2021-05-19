/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Formatter {

	func getDateFrom(dateString8601 string: String) -> Date? {

		let validFormatOptions: [ISO8601DateFormatter.Options] = [
			[.withInternetDateTime, .withFractionalSeconds, .withTimeZone],
			[.withInternetDateTime, .withFractionalSeconds],
			[.withInternetDateTime, .withTimeZone],
			[.withInternetDateTime],
			[.withFullDate]
		]

		let formatter = ISO8601DateFormatter()
		for formatOptions in validFormatOptions {

			formatter.formatOptions = formatOptions
			if let date = formatter.date(from: string) {
				return date
			}
		}
		return nil
	}
}
