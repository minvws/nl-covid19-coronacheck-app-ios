/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

extension DateFormatter {
	
	/// Display date formatter
	enum Format { }
	/// Server date formatter
	enum Header { }
	/// Event date formatter
	enum Event { }
	
	static let format = Format.self
	static let header = Header.self
	static let event = Event.self
	
	/// Initializes a date formatter with `Europe/Amsterdam` identifier with a custom `format` string parameter.
	/// - Parameter format: The date format as string
	convenience init(format: String) {
		self.init()
		dateFormat = format
		timeZone = TimeZone(identifier: "Europe/Amsterdam")
	}
}

extension DateFormatter.Format {

	/// e.g. `3 May 09:54`
	static let dayMonthWithTime = {
		DateFormatter(format: "d MMMM HH:mm")
	}()
	
	/// e.g. `3 May 2022`
	static let dayMonthYear = {
		DateFormatter(format: "d MMMM yyyy")
	}()
	
	/// e.g. `3 May 2022 09:54`
	static let dayMonthYearWithTime = {
		DateFormatter(format: "d MMMM yyyy HH:mm")
	}()
	
	/// e.g. `Tuesday 3 May 09:54`
	static let dayNameDayNumericMonthWithTime = {
		DateFormatter(format: "EEEE d MMMM HH:mm")
	}()
	
	/// e.g. `Tuesday 3 May`
	static let dayNameDayNumericMonth = {
		DateFormatter(format: "EEEE d MMMM")
	}()
	
	/// e.g. `Tuesday 3 May 2022 09:54`
	static let dayNameDayNumericMonthYearWithTime = {
		DateFormatter(format: "EEEE d MMMM yyyy HH:mm")
	}()
	
	/// e.g. `May`
	static let month = {
		DateFormatter(format: "MMMM")
	}()
	
	/// e.g. `03-05-2022`
	static let numericDate = {
		DateFormatter(format: "dd-MM-yyyy")
	}()
	
	/// e.g. `03-05-2022 09:54`
	static let numericDateWithTime = {
		DateFormatter(format: "dd-MM-yyyy HH:mm")
	}()
	
	// MARK: - Time
	
	/// e.g. `"4 hours, 55 minutes"`
	/// 	 `"59 minutes"`
	/// 	 `"20 seconds"`
	static let hoursMinutesSecondsRelative: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.hour, .minute, .second]
		return formatter
	}()

	/// e.g. `"4 hours, 55 minutes"`
	/// 	 `"59 minutes"`
	static let hoursMinutesRelative: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.hour, .minute]
		return formatter
	}()

	/// e.g. `"3 days"`
	/// 	 `"0 days"`
	static let daysRelative: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.day]
		return formatter
	}()
}

extension DateFormatter.Header {
	
	/// e.g. `Tue, 3 May 2022 09:58:24 CEST`
	static let serverDate: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_GB") // because the server date contains day name
		dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
		return dateFormatter
	}()
}

extension DateFormatter.Event {
	
	/// e.g. `2022-05-02`
	static let iso8601: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()
}
