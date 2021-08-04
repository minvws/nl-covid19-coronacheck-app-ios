/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct EventDetails {
	let field: EventDetailable
	let value: String?
}

protocol EventDetailable {
	
	/// Required or optional field
	var isRequired: Bool { get }
	
	/// The display title of the field
	var displayTitle: String { get }
	
	/// Show additional line break after field
	var hasLineBreak: Bool { get }
}

enum EventDetailsVaccination: EventDetailable {
	case subtitle
	case name
	case dateOfBirth
	case pathogen
	case vaccineBrand
	case vaccineType
	case vaccineManufacturer
	case dosage
	case completionReason
	case date
	case country
	case uniqueIdentifer
	
	var isRequired: Bool {
		switch self {
			case .dosage, .completionReason: return false
			default: return true
		}
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holderEventAboutVaccinationSubtitle()
			case .name: return L.holderEventAboutVaccinationName()
			case .dateOfBirth: return L.holderEventAboutVaccinationDateofbirth()
			case .pathogen: return L.holderEventAboutVaccinationPathogen()
			case .vaccineBrand: return L.holderEventAboutVaccinationBrand()
			case .vaccineType: return L.holderEventAboutVaccinationType()
			case .vaccineManufacturer: return L.holderEventAboutVaccinationManufacturer()
			case .dosage: return L.holderEventAboutVaccinationDosage()
			case .completionReason: return L.holderEventAboutVaccinationCompletionreason()
			case .date: return L.holderEventAboutVaccinationDate()
			case .country: return L.holderEventAboutVaccinationCountry()
			case .uniqueIdentifer: return L.holderEventAboutVaccinationIdentifier()
		}
	}
	
	var hasLineBreak: Bool {
		switch self {
			case .subtitle, .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsTest: EventDetailable {
	case subtitle
	case name
	case dateOfBirth
	case testType
	case testName
	case date
	case result
	case facility
	case manufacturer
	case uniqueIdentifer
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holderEventAboutTestSubtitle()
			case .name: return L.holderEventAboutTestName()
			case .dateOfBirth: return L.holderEventAboutTestDateofbirth()
			case .testType: return L.holderEventAboutTestType()
			case .testName: return L.holderEventAboutTestTestname()
			case .date: return L.holderEventAboutTestDate()
			case .result: return L.holderEventAboutTestResult()
			case .facility: return L.holderEventAboutTestFacility()
			case .manufacturer: return L.holderEventAboutTestManufacturer()
			case .uniqueIdentifer: return L.holderEventAboutTestIdentifier()
		}
	}
	
	var hasLineBreak: Bool {
		switch self {
			case .subtitle, .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsRecovery: EventDetailable {
	case subtitle
	case name
	case dateOfBirth
	case date
	case validFrom
	case validUntil
	case uniqueIdentifer
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holderEventAboutRecoverySubtitle()
			case .name: return L.holderEventAboutRecoveryName()
			case .dateOfBirth: return L.holderEventAboutRecoveryDateofbirth()
			case .date: return L.holderEventAboutRecoveryDate()
			case .validFrom: return L.holderEventAboutRecoveryValidfrom()
			case .validUntil: return L.holderEventAboutRecoveryValiduntil()
			case .uniqueIdentifer: return L.holderEventAboutRecoveryIdentifier()
		}
	}
	
	var hasLineBreak: Bool {
		switch self {
			case .subtitle, .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsDCCVaccination: EventDetailable {
	case subtitle
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
	case certificateIdentifier
	
	var isRequired: Bool {
		switch self {
			case .dosage: return false
			default: return true
		}
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holderDccVaccinationSubtitle()
			case .name: return L.holderDccVaccinationName()
			case .dateOfBirth: return L.holderDccVaccinationDateofbirth()
			case .pathogen: return L.holderDccVaccinationPathogen()
			case .vaccineBrand: return L.holderDccVaccinationBrand()
			case .vaccineType: return L.holderDccVaccinationType()
			case .vaccineManufacturer: return L.holderDccVaccinationManufacturer()
			case .dosage: return L.holderDccVaccinationDosage()
			case .date: return L.holderDccVaccinationDate()
			case .country: return L.holderDccVaccinationCountry()
			case .issuer: return L.holderDccVaccinationIssuer()
			case .certificateIdentifier: return L.holderDccVaccinationIdentifier()
		}
	}
	
	var hasLineBreak: Bool {
		switch self {
			case .subtitle, .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsDCCTest: EventDetailable {
	case subtitle
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
	case certificateIdentifier
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holderDccTestSubtitle()
			case .name: return L.holderDccTestName()
			case .dateOfBirth: return L.holderDccTestDateofbirth()
			case .pathogen: return L.holderDccTestPathogen()
			case .testType: return L.holderDccTestType()
			case .testName: return L.holderDccTestTestname()
			case .date: return L.holderDccTestDate()
			case .result: return L.holderDccTestResult()
			case .facility: return L.holderDccTestFacility()
			case .manufacturer: return L.holderDccTestManufacturer()
			case .country: return L.holderDccTestCountry()
			case .issuer: return L.holderDccTestIssuer()
			case .certificateIdentifier: return L.holderDccTestIdentifier()
		}
	}
	
	var hasLineBreak: Bool {
		switch self {
			case .subtitle, .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsDCCRecovery: EventDetailable {
	case subtitle
	case name
	case dateOfBirth
	case pathogen
	case date
	case country
	case issuer
	case validFrom
	case validUntil
	case certificateIdentifier
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holderDccRecoverySubtitle()
			case .name: return L.holderDccRecoveryName()
			case .dateOfBirth: return L.holderDccRecoveryDateofbirth()
			case .pathogen: return L.holderDccRecoveryPathogen()
			case .date: return L.holderDccRecoveryDate()
			case .country: return L.holderDccRecoveryCountry()
			case .issuer: return L.holderDccRecoveryIssuer()
			case .validFrom: return L.holderDccRecoveryValidfrom()
			case .validUntil: return L.holderDccRecoveryValiduntil()
			case .certificateIdentifier: return L.holderDccRecoveryIdentifier()
		}
	}
	
	var hasLineBreak: Bool {
		switch self {
			case .subtitle, .dateOfBirth: return true
			default: return false
		}
	}
}
