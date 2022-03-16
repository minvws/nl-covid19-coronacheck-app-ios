/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum QRCodeOriginType: String, Codable, Equatable {
	case test
	case vaccination
	case recovery
	case vaccinationassessment

	// e.g. "Test Certificate", "Vaccination Certificate"
	var localizedProof: String {
		switch self {
			case .recovery: return L.general_recoverycertificate()
			case .vaccination: return L.general_vaccinationcertificate()
			case .test: return L.general_testcertificate()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}
	
	// e.g. "Internationaal vaccinatiebewijs"
	var localizedProofInternational0G: String {
		switch self {
			case .recovery: return L.general_recoverycertificate_0G()
			case .vaccination: return L.general_vaccinationcertificate_0G()
			case .test: return L.general_testcertificate_0G()
			case .vaccinationassessment: return localizedProof
		}
	}

	/// There is a particular order to sort these onscreen
	var customSortIndex: Int {
		switch self {
			case .vaccination: return 0
			case .recovery: return 1
			case .vaccinationassessment: return 2
			case .test: return 3
		}
	}
}
