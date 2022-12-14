/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	
	/// Show additional line break before field
	var isPrecededByLineBreak: Bool { get }

	/// Show additional line break after field
	var isFollowedByLineBreak: Bool { get }
	
	/// Show a separator line
	var isSeparator: Bool { get }
}

enum EventDetailsVaccination: EventDetailable {
	case subtitle(provider: String)
	case name
	case dateOfBirth
	case pathogen
	case vaccineBrand
	case vaccineProductname
	case vaccineType
	case vaccineManufacturer
	case dosage
	case completionReason
	case date
	case country
	case uniqueIdentifer
	case separator
	
	var isRequired: Bool {
		switch self {
			case .dosage, .completionReason, .separator: return false
			default: return true
		}
	}
	
	var displayTitle: String {
		switch self {
			case let .subtitle(provider): return L.holderEventAboutVaccinationSubtitle(provider)
			case .name: return L.holderEventAboutVaccinationName()
			case .dateOfBirth: return L.holderEventAboutVaccinationDateofbirth()
			case .pathogen: return L.holderEventAboutVaccinationPathogen()
			case .vaccineBrand: return L.holderEventAboutVaccinationBrand()
			case .vaccineProductname: return L.holder_event_aboutVaccination_productName()
			case .vaccineType: return L.holderEventAboutVaccinationType()
			case .vaccineManufacturer: return L.holderEventAboutVaccinationManufacturer()
			case .dosage: return L.holderEventAboutVaccinationDosage()
			case .completionReason: return L.holderEventAboutVaccinationCompletionreason()
			case .date: return L.holderEventAboutVaccinationDate()
			case .country: return L.holderEventAboutVaccinationCountry()
			case .uniqueIdentifer: return L.holderEventAboutVaccinationIdentifier()
			case .separator: return ""
		}
	}
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .pathogen, .uniqueIdentifer: return true
			default: return false
		}
	}
	
	var isFollowedByLineBreak: Bool {
		if case .uniqueIdentifer = self {
			return true
		}
		return false
	}

	var isSeparator: Bool {

		switch self {
			case .separator: return true
			default: return false
		}
	}
}

enum EventDetailsVaccinationAssessment: EventDetailable {
	case subtitle
	case name
	case dateOfBirth
	case date
	case country
	case uniqueIdentifer
	
	var isRequired: Bool {
		return true
	}
	
	var displayTitle: String {
		switch self {
			case .subtitle: return L.holder_event_vaccination_assessment_about_subtitle()
			case .name: return L.holder_event_vaccination_assessment_about_name()
			case .dateOfBirth: return L.holder_event_vaccination_assessment_about_date_of_birth()
			case .date: return L.holder_event_vaccination_assessment_about_date()
			case .country: return L.holder_event_vaccination_assessment_about_country()
			case .uniqueIdentifer: return L.holder_event_vaccination_assessment_about_unique_identifier()
		}
	}
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .uniqueIdentifer, .date: return true
			default: return false
		}
	}
	
	var isFollowedByLineBreak: Bool {
		if case .uniqueIdentifer = self {
			return true
		}
		return false
	}
	
	var isSeparator: Bool {
		return false
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
	case countryTestedIn
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
			case .countryTestedIn: return L.holder_event_about_test_countrytestedin()
		}
	}
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .testType, .uniqueIdentifer: return true
			default: return false
		}
	}

	var isFollowedByLineBreak: Bool {

		return false
	}
	
	var isSeparator: Bool {
		return false
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
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .date: return true
			default: return false
		}
	}
	
	var isFollowedByLineBreak: Bool {
		if case .uniqueIdentifer = self {
			return true
		}
		return false
	}
	
	var isSeparator: Bool {
		return false
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
			case .subtitle: return L.holder_dccDetails_subtitle()
			case .name: return L.holderDccVaccinationName()
			case .dateOfBirth: return L.holderDccVaccinationDateofbirth()
			case .pathogen: return L.holderDccVaccinationPathogen()
			case .vaccineBrand: return L.holderDccVaccinationBrand()
			case .vaccineType: return L.holderDccVaccinationType()
			case .vaccineManufacturer: return L.holderDccVaccinationManufacturer()
			case .dosage: return L.holderDccVaccinationDosage()
			case .date: return L.holderDccVaccinationDate()
			case .country: return L.holderDccVaccinationCountry()
			case .issuer: return L.holder_dcc_issuer()
			case .certificateIdentifier: return L.holderDccVaccinationIdentifier()
		}
	}
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .pathogen, .certificateIdentifier: return true
			default: return false
		}
	}
	
	var isFollowedByLineBreak: Bool {
		if case .certificateIdentifier = self {
			return true
		}
		return false
	}

	var isSeparator: Bool {
		return false
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
			case .subtitle: return L.holder_dccDetails_subtitle()
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
			case .issuer: return L.holder_dcc_issuer()
			case .certificateIdentifier: return L.holderDccTestIdentifier()
		}
	}
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .pathogen, .certificateIdentifier: return true
			default: return false
		}
	}
	
	var isFollowedByLineBreak: Bool {
		if case .certificateIdentifier = self {
			return true
		}
		return false
	}

	var isSeparator: Bool {
		return false
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
			case .subtitle: return L.holder_dccDetails_subtitle()
			case .name: return L.holderDccRecoveryName()
			case .dateOfBirth: return L.holderDccRecoveryDateofbirth()
			case .pathogen: return L.holderDccRecoveryPathogen()
			case .date: return L.holderDccRecoveryDate()
			case .country: return L.holderDccRecoveryCountry()
			case .issuer: return L.holder_dcc_issuer()
			case .validFrom: return L.holderDccRecoveryValidfrom()
			case .validUntil: return L.holderDccRecoveryValiduntil()
			case .certificateIdentifier: return L.holderDccRecoveryIdentifier()
		}
	}
	
	var isPrecededByLineBreak: Bool {
		switch self {
			case .name, .pathogen, .date, .validFrom: return true
			default: return false
		}
	}
	
	var isFollowedByLineBreak: Bool {
		if case .certificateIdentifier = self {
			return true
		}
		return false
	}

	var isSeparator: Bool {
		return false
	}
}

extension EventDetails: Equatable {
	
	static func == (lhs: EventDetails, rhs: EventDetails) -> Bool {
		return
			lhs.field.displayTitle == rhs.field.displayTitle &&
			lhs.field.isRequired == rhs.field.isRequired &&
			lhs.field.isPrecededByLineBreak == rhs.field.isPrecededByLineBreak &&
			lhs.field.isFollowedByLineBreak == rhs.field.isFollowedByLineBreak &&
			lhs.field.isSeparator == rhs.field.isSeparator &&
			lhs.value == rhs.value
	}
}
