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
	
	var isRequired: Bool { get }
	
	var displayTitle: String { get }
	
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
	case certificateIdentifier
	
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
			case .certificateIdentifier: return L.holderEventAboutVaccinationIdentifier()
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
	case name
	case dateOfBirth
	case testType
	case testName
	case result
	case location
	case manufacturer
	case certificateIdentifier
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String { "" }
	
	var hasLineBreak: Bool {
		switch self {
			case .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsRecovery: EventDetailable {
	case name
	case dateOfBirth
	case date
	case validFrom
	case expiresAt
	case certificateIdentifier
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String { "" }
	
	var hasLineBreak: Bool {
		switch self {
			case .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsDCCVaccination: EventDetailable {
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
		return true
	}
	
	var displayTitle: String { "" }
	
	var hasLineBreak: Bool {
		switch self {
			case .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsDCCTest: EventDetailable {
	case name
	case dateOfBirth
	case pathogen
	case testType
	case testName
	case result
	case location
	case manufacturer
	case country
	case issuer
	case certificateIdentifier
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String { "" }
	
	var hasLineBreak: Bool {
		switch self {
			case .dateOfBirth: return true
			default: return false
		}
	}
}

enum EventDetailsDCCRecovery: EventDetailable {
	case name
	case dateOfBirth
	case pathogen
	case date
	case country
	case issuer
	case validFrom
	case expiresAt
	case certificateIdentifier
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String { "" }
	
	var hasLineBreak: Bool {
		switch self {
			case .dateOfBirth: return true
			default: return false
		}
	}
}
