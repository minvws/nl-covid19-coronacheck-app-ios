/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Formatter {

	static let iso8601MicroSeconds: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()

	static let iso8601NoMicroSecond: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]
		return formatter
	}()

	static let iso8601DateOnly: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate]
		return formatter
	}()

	func getDateFrom(dateString8601 string: String) -> Date? {

		if let date = Formatter.iso8601MicroSeconds.date(from: string) {
			return date
		}
		if let date = Formatter.iso8601NoMicroSecond.date(from: string) {
			return date
		}
		if let date = Formatter.iso8601DateOnly.date(from: string) {
			return date
		}
		return nil
	}
}
