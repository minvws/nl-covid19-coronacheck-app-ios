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
	
	static let format = Format.self
	static let header = Header.self
}

extension DateFormatter.Format {

	/// e.g. `10 August 15:18`
	static let dayAndMonthWithTimeFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `3 May 2022`
	static let dayMonthYearFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM yyyy"
		return dateFormatter
	}()
	
	/// e.g. `Tuesday 3 May 09:53`
	static let dayNameDayNumericMonthWithTimeFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `Tuesday 3 May`
	static let dayNameDayNumericMonthFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM"
		return dateFormatter
	}()
	
	/// e.g. `Tuesday 3 May 2022 09:54`
	static let dayNameDayNumericMonthYearWithTimeFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM yyyy HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `May`
	static let monthFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter
	}()
	
	/// e.g. `03-05-2022`
	static let numericDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()
	
	// MARK: - Event
	
	/// e.g. `2022-05-02`
	static let iso8601DateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()
	
	// MARK: - Time
	
	/// e.g. `"4 hours, 55 minutes"`
	/// 	 `"59 minutes"`
	/// 	 `"20 seconds"`
	static let hoursMinutesSecondsRelativeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.hour, .minute, .second]
		return formatter
	}()

	/// e.g. `"4 hours, 55 minutes"`
	/// 	 `"59 minutes"`
	static let hoursMinutesFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.hour, .minute]
		return formatter
	}()

	/// e.g. `"3 days"`
	/// 	 `"0 days"`
	static let daysRelativeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.day]
		return formatter
	}()
}

extension DateFormatter.Header {
	
	/// e.g. `Tue, 3 May 2022 09:58:24 CEST`
	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_GB") // because the server date contains day name
		dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
		return dateFormatter
	}()
}
