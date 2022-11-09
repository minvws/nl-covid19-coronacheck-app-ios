/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Formatter {

	static func getDateFrom(dateString8601 string: String) -> Date? {

		// None of the options seems to handle no seconds.
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
		if let date = dateFormatter.date(from: string) {
			return date
		}
		var incomingDate = string
		var validFormatOptions: [ISO8601DateFormatter.Options] = []
		
		if #available(iOS 11.2, *) {
			// Try the different options for an iOS8601 date
			validFormatOptions = [
				[.withInternetDateTime, .withFractionalSeconds, .withTimeZone],
				[.withInternetDateTime, .withFractionalSeconds],
				[.withInternetDateTime, .withTimeZone],
				[.withInternetDateTime],
				[.withFullDate, .withTimeZone],
				[.withFullDate]
			]
		} else {
			validFormatOptions = [
				[.withInternetDateTime, .withTimeZone],
				[.withInternetDateTime],
				[.withFullDate, .withTimeZone],
				[.withFullDate]
			]
			incomingDate = incomingDate.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
		}
		
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
