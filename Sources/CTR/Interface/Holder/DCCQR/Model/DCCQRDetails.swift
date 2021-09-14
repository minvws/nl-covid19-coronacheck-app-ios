/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct DCCQRDetails {
	let field: DCCQRDetailable
	let value: String?
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
		return ""
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
		return ""
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
		return ""
	}
}
