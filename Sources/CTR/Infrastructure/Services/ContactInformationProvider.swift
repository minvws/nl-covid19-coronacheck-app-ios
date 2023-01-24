/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol ContactInformationProtocol {
	
	/// The phone number for the helpdesk
	var phoneNumberLink: String { get }
	
	/// The phone number for the helpsdesk when calling outside NL
	var phoneNumberAbroadLink: String { get }
	
	/// The first weekday the helpdesk is open
	var startDay: String { get }
	
	/// The last weekday the helpdesk is open
	var endDay: String { get }
	
	/// The start of the opening hours
	var startHour: String { get }
	
	/// The end of the opening hours.
	var endHour: String { get }
}

class ContactInformationProvider: ContactInformationProtocol {
	
	var phoneNumberLink: String {
		let number = remoteConfigManager?.storedConfiguration.contactInformation?.phoneNumber ?? "0800 - 1421"
		return "<a href=\"tel:\(number.strippingWhitespace())\">\(number)</a>"
	}
	
	var phoneNumberAbroadLink: String {
		let number = remoteConfigManager?.storedConfiguration.contactInformation?.phoneNumberAbroad ?? "+31 70 750 37 20"
		return "<a href=\"tel:\(number.strippingWhitespace())\">\(number)</a>"
	}
	
	var startDay: String {
		if let contactInfo = remoteConfigManager?.storedConfiguration.contactInformation,
		   let start = contactInfo.startDay, start >= 0, start <= 6 {
			return Calendar.current.weekdaySymbols[start]
		}
		// Fallback
		return Calendar.current.weekdaySymbols[1]
	}
	
	var endDay: String {
		if let contactInfo = remoteConfigManager?.storedConfiguration.contactInformation,
		   let end = contactInfo.endDay, end >= 0, end <= 6 {
			return Calendar.current.weekdaySymbols[end]
		}
		// Fallback
		return Calendar.current.weekdaySymbols[5]
	}
	
	var startHour: String {
		let start = remoteConfigManager?.storedConfiguration.contactInformation?.startHour ?? "08:00"
		if let startDate = DateFormatter.Format.time.date(from: start) {
			return DateFormatter.Format.localizedTime.string(from: startDate)
		}
		return start
	}
	
	var endHour: String {
		let end = remoteConfigManager?.storedConfiguration.contactInformation?.endHour ?? "18:00"
		if let endDate = DateFormatter.Format.time.date(from: end) {
			return DateFormatter.Format.localizedTime.string(from: endDate)
		}
		return end
	}
	
	private let remoteConfigManager: RemoteConfigManaging?
	
	init(remoteConfigManager: RemoteConfigManaging) {
		self.remoteConfigManager = remoteConfigManager
	}
}
