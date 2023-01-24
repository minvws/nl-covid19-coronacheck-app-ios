/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol ContactInformationProtocol {
	
	var phoneNumberLink: String { get }
	var phoneNumberAbroadLink: String { get }
	var startDay: String { get }
	var endDay: String { get }
	var startHour: String { get }
	var endHour: String { get }
}

struct ContactInformationProvider: ContactInformationProtocol {
	
	var phoneNumberLink: String
	var phoneNumberAbroadLink: String
	var startDay: String
	var endDay: String
	var startHour: String
	var endHour: String
	
	init() {
		
		phoneNumberLink = "<a href=\"tel: 0800-1421\">0800-1421</a>"
		phoneNumberAbroadLink = "<a href=\"tel:+31707503720\">+31 70 750 37 20</a>"
		
		startDay = Calendar.current.weekdaySymbols[1]
		endDay = Calendar.current.weekdaySymbols[5]
		
		let importDateFormatter = DateFormatter()
		importDateFormatter.dateFormat = "HH:mm"
		if let start = importDateFormatter.date(from: "08:00"),
		   let end = importDateFormatter.date(from: "18:00") {
			
			let printDateFormatter = DateFormatter()
			printDateFormatter.dateStyle = .none
			printDateFormatter.timeStyle = .short
			
			startHour = printDateFormatter.string(from: start)
			endHour = printDateFormatter.string(from: end)
		} else {
			startHour = "08:00"
			endHour = "18:00"
		}
	}
}
