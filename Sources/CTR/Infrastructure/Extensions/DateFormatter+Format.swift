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
	static let dayMonthWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `3 May 2022`
	static let dayMonthYear: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM yyyy"
		return dateFormatter
	}()
	
	/// e.g. `3 May 2022 09:53`
	static let dayMonthYearWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM yyyy HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `Tuesday 3 May 09:53`
	static let dayNameDayNumericMonthWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `Tuesday 3 May`
	static let dayNameDayNumericMonth: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM"
		return dateFormatter
	}()
	
	/// e.g. `Tuesday 3 May 2022 09:54`
	static let dayNameDayNumericMonthYearWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM yyyy HH:mm"
		return dateFormatter
	}()
	
	/// e.g. `May`
	static let month: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter
	}()
	
	/// e.g. `03-05-2022`
	static let numericDate: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()
	
	/// e.g. `13-10-2021 09:54`
	static let numericDateWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
		return dateFormatter
	}()
	
	// MARK: - Event
	
	/// e.g. `2022-05-02`
	static let iso8601: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
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
