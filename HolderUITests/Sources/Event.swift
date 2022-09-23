/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

open class Event {
	
	let type: EventType
	let eventDate: Date
	private let countryCode: Country
	let validFrom: Date?
	let validUntil: Date?
	let disease: String
	let dcc: String?
	let couplingCode: String?
	
	var internationalEventCertificate: String {
		switch self.type {
			case .vaccination:
				return "Internationaal vaccinatiebewijs"
			case .positiveTest:
				return "Internationaal herstelbewijs"
			case .negativeTest:
				return "Internationaal testbewijs"
		}
	}
	
	var country: String {
		switch countryCode {
			case .nl:
				return "Nederland"
			case .de:
				return "Duitsland"
		}
	}
	
	var countryInternational: String {
		switch countryCode {
			case .nl:
				return "Nederland / The Netherlands"
			case .de:
				return "Duitsland / Germany"
		}
	}
	
	init(
		type: EventType,
		eventDate: Date,
		country: Country,
		validFrom: Date? = nil,
		validUntil: Date? = nil,
		dcc: String? = nil,
		couplingCode: String? = nil
	) {
		self.type = type
		self.eventDate = eventDate
		self.countryCode = country
		self.disease = "COVID-19"
		self.validFrom = validFrom
		self.validUntil = validUntil
		self.dcc = dcc
		self.couplingCode = couplingCode
	}
	
	enum EventType {
		case vaccination
		case positiveTest
		case negativeTest
	}
	
	enum Country {
		case nl
		case de
	}
	
	enum TestType: String {
		case pcr = "PCR (NAAT)"
		case rat = "Sneltest (RAT)"
	}
}

final class Vaccination: Event {
	
	let vaccine: VaccineType
	
	init(
		eventDate: Date,
		country: Country = .nl,
		validFrom: Date? = nil,
		validUntil: Date? = nil,
		dcc: String? = nil,
		couplingCode: String? = nil,
		vaccine: VaccineType
	) {
		self.vaccine = vaccine
		
		super.init(
			type: .vaccination,
			eventDate: eventDate,
			country: country,
			validFrom: validFrom,
			validUntil: validUntil,
			dcc: dcc,
			couplingCode: couplingCode
		)
	}
	
	enum VaccineType: String {
		case pfizer = "Pfizer (Comirnaty)"
		case moderna = "Moderna"
		case janssen = "Janssen (COVID-19 Vaccin Janssen)"
	}
}

final class PositiveTest: Event {
	
	let testType: TestType
	
	init(
		eventDate: Date,
		country: Country = .nl,
		validFrom: Date? = nil,
		validUntil: Date? = nil,
		dcc: String? = nil,
		couplingCode: String? = nil,
		testType: TestType
	) {
		self.testType = testType
		
		super.init(
			type: .positiveTest,
			eventDate: eventDate,
			country: country,
			validFrom: validFrom,
			validUntil: validUntil,
			dcc: dcc,
			couplingCode: couplingCode
		)
	}
}

final class NegativeTest: Event {
	
	let testType: TestType
	
	init(
		eventDate: Date,
		country: Country = .nl,
		validFrom: Date? = nil,
		validUntil: Date? = nil,
		dcc: String? = nil,
		couplingCode: String? = nil,
		testType: TestType
	) {
		self.testType = testType
		
		super.init(
			type: .negativeTest,
			eventDate: eventDate,
			country: country,
			validFrom: validFrom,
			validUntil: validUntil,
			dcc: dcc,
			couplingCode: couplingCode
		)
	}
}