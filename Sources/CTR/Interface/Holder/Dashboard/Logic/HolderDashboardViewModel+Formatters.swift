/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// MARK: - Date Formatters

extension HolderDashboardViewModel {

	/// e.g. `10 August 2021`
	static let dateWithoutTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM yyyy"
		return formatter
	}()

	/// e.g. `10 August 15:17`
	static let dateWithTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM HH:mm"
		return formatter
	}()

	/// e.g. `Tuesday 10 August 15:18`
	static let dateWithDayAndTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE d MMMM HH:mm"
		return formatter
	}()

	/// e.g. `10 August`
	static let dayAndMonthFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM"
		return formatter
	}()

	/// e.g. `10 August 15:18`
	static let dayAndMonthWithTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMMM HH:mm"
		return formatter
	}()

	/// e.g. `"4 hours, 55 minutes"`
	/// 	 `"59 minutes"`
	/// 	 `"20 seconds"`
	static let hmsRelativeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.hour, .minute, .second]
		return formatter
	}()

	/// e.g. `"4 hours, 55 minutes"`
	/// 	 `"59 minutes"`
	static let hmRelativeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.hour, .minute]
		return formatter
	}()

	/// e.g. `"23 hrs, 59 min"`
	/// 	 `23 uur, 59 min`
	/// 	 `"1 min"`
	static let hmShortRelativeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .short
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
