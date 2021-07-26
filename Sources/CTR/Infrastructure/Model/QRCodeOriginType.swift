/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum QRCodeOriginType: String, Codable {
	case test
	case vaccination
	case recovery

	// e.g. "Test Certificate", "Vaccination Certificate"
	var localizedProof: String {
		switch self {
			case .recovery: return L.generalRecoverystatement()
			case .vaccination: return L.generalVaccinationcertificate()
			case .test: return L.generalTestcertificate()
		}
	}

	// e.g. "Test Date", "Vaccination Date" etc.
	var localizedEvent: String {
		switch self {
			case .recovery: return L.generalRecoverydate()
			case .vaccination: return L.generalVaccinationdate()
			case .test: return L.generalTestdate()
		}
	}

	/// There is a particular order to sort these onscreen
	var customSortIndex: Int {
		switch self {
			case .vaccination: return 0
			case .recovery: return 1
			case .test: return 2
		}
	}
}
