/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// MARK: - Date Formatters

extension HolderDashboardViewModel {

	static let dateWithoutTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM yyyy"
		return formatter
	}()

	static let dateWithTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM HH:mm"
		return formatter
	}()

	static let dateWithDayAndTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE d MMMM HH:mm"
		return formatter
	}()

	static let dayAndMonthFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM"
		return formatter
	}()

	static let dayAndMonthWithTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM HH:mm"
		return formatter
	}()

	// e.g. "4 hours, 55 minutes"
	// 		"59 minutes"
	// 		"20 seconds"
	static let hmsRelativeFormatter: DateComponentsFormatter = {
		let hoursFormatter = DateComponentsFormatter()
		hoursFormatter.unitsStyle = .full
		hoursFormatter.maximumUnitCount = 2
		hoursFormatter.allowedUnits = [.hour, .minute, .second]
		return hoursFormatter
	}()

	// e.g. "4 hours, 55 minutes"
	// 		"59 minutes"
	static let hmRelativeFormatter: DateComponentsFormatter = {
		let hoursFormatter = DateComponentsFormatter()
		hoursFormatter.unitsStyle = .full
		hoursFormatter.maximumUnitCount = 2
		hoursFormatter.allowedUnits = [.hour, .minute]
		return hoursFormatter
	}()

	static let daysRelativeFormatter: DateComponentsFormatter = {
		let hoursFormatter = DateComponentsFormatter()
		hoursFormatter.unitsStyle = .full
		hoursFormatter.allowedUnits = [.day]
		return hoursFormatter
	}()
}
