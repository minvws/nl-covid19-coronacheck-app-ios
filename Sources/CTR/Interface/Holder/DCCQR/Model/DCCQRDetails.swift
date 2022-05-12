/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct DCCQRDetails {
	let field: DCCQRDetailable
	let value: String?
	var dosageMessage: String?
}

protocol DCCQRDetailable {
	
	/// The display title of the field
	var displayTitle: String { get }
}

enum DCCQRDetailsVaccination: DCCQRDetailable {
	case name
	case dateOfBirth
	case pathogen
	case vaccineBrand
	case vaccineType
	case vaccineManufacturer
	case dosage
	case date
	case country
	case issuer
	case uniqueIdentifer
	
	var displayTitle: String {
		switch self {
			case .name: return L.holderShowqrEuAboutVaccinationName()
			case .dateOfBirth: return L.holderShowqrEuAboutVaccinationDateofbirth()
			case .pathogen: return L.holderShowqrEuAboutVaccinationPathogen()
			case .vaccineBrand: return L.holderShowqrEuAboutVaccinationBrand()
			case .vaccineType: return L.holderShowqrEuAboutVaccinationType()
			case .vaccineManufacturer: return L.holderShowqrEuAboutVaccinationManufacturer()
			case .dosage: return L.holderShowqrEuAboutVaccinationDosage()
			case .date: return L.holderShowqrEuAboutVaccinationDate()
			case .country: return L.holderShowqrEuAboutVaccinationCountry()
			case .issuer: return L.holderShowqrEuAboutVaccinationIssuer()
			case .uniqueIdentifer: return L.holderShowqrEuAboutVaccinationIdentifier()
		}
	}
}

enum DCCQRDetailsTest: DCCQRDetailable {
	case name
	case dateOfBirth
	case pathogen
	case testType
	case testName
	case date
	case result
	case facility
	case manufacturer
	case country
	case issuer
	case uniqueIdentifer
	
	var displayTitle: String {
		switch self {
			case .name: return L.holderShowqrEuAboutTestName()
			case .dateOfBirth: return L.holderShowqrEuAboutTestDateofbirth()
			case .pathogen: return L.holderShowqrEuAboutTestPathogen()
			case .testType: return L.holderShowqrEuAboutTestType()
			case .testName: return L.holderShowqrEuAboutTestTestname()
			case .date: return L.holderShowqrEuAboutTestDate()
			case .result: return L.holderShowqrEuAboutTestResult()
			case .facility: return L.holderShowqrEuAboutTestFacility()
			case .manufacturer: return L.holderShowqrEuAboutTestManufacturer()
			case .country: return L.holderShowqrEuAboutTestCountry()
			case .issuer: return L.holderShowqrEuAboutTestIssuer()
			case .uniqueIdentifer: return L.holderShowqrEuAboutTestIdentifier()
		}
	}
}

enum DCCQRDetailsRecovery: DCCQRDetailable {
	case name
	case dateOfBirth
	case pathogen
	case date
	case country
	case issuer
	case validFrom
	case validUntil
	case uniqueIdentifer
	
	var displayTitle: String {
		switch self {
			case .name: return L.holderShowqrEuAboutRecoveryName()
			case .dateOfBirth: return L.holderShowqrEuAboutRecoveryDateofbirth()
			case .pathogen: return L.holderShowqrEuAboutRecoveryPathogen()
			case .date: return L.holderShowqrEuAboutRecoveryDate()
			case .country: return L.holderShowqrEuAboutRecoveryCountry()
			case .issuer: return L.holderShowqrEuAboutRecoveryIssuer()
			case .validFrom: return L.holderShowqrEuAboutRecoveryValidfrom()
			case .validUntil: return L.holderShowqrEuAboutRecoveryValiduntil()
			case .uniqueIdentifer: return L.holderShowqrEuAboutRecoveryIdentifier()
		}
	}
}

extension DCCQRDetails: Equatable {
	
	static func == (lhs: DCCQRDetails, rhs: DCCQRDetails) -> Bool {
		return lhs.field.displayTitle == rhs.field.displayTitle &&
			lhs.value == rhs.value
	}
}
