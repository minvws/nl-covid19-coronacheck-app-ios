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
	let eventCountry: Country
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
	
	init(
		type: EventType,
		eventDate: Date,
		country: Country,
		dcc: String? = nil,
		couplingCode: String? = nil
	) {
		self.type = type
		self.eventDate = eventDate
		self.disease = "COVID-19"
		self.eventCountry = country
		self.dcc = dcc
		self.couplingCode = couplingCode
	}
	
	enum EventType {
		case vaccination
		case positiveTest
		case negativeTest
	}
	
	enum Country: String {
		case nl = "Nederland / The Netherlands"
	}
}

final class Vaccination: Event {
	
	let vaccine: VaccineType
	
	init(
		eventDate: Date,
		country: Country = .nl,
		dcc: String? = nil,
		couplingCode: String? = nil,
		vaccine: VaccineType
	) {
		self.vaccine = vaccine
		
		super.init(
			type: .vaccination,
			eventDate: eventDate,
			country: country,
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
	
	init(
		eventDate: Date,
		country: Country = .nl,
		dcc: String? = nil,
		couplingCode: String? = nil
	) {
		super.init(
			type: .positiveTest,
			eventDate: eventDate,
			country: country,
			dcc: dcc,
			couplingCode: couplingCode
		)
	}
}

final class NegativeTest: Event {
	
	init(
		eventDate: Date,
		country: Country = .nl,
		dcc: String? = nil,
		couplingCode: String? = nil
	) {
		super.init(
			type: .negativeTest,
			eventDate: eventDate,
			country: country,
			dcc: dcc,
			couplingCode: couplingCode
		)
	}
}
