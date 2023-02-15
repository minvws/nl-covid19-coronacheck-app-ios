/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import Resources

extension OriginType {
	
	public var localized: String {
		switch self {
			case .recovery: return L.general_recoverycertificate()
			case .vaccination: return L.general_vaccination()
			case .test: return L.general_negativeTest()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}
	
	/// e.g. "Test Certificate", "Vaccination Certificate"
	public var localizedProof: String {
		switch self {
			case .recovery: return L.general_recoverycertificate()
			case .vaccination: return L.general_vaccinationcertificate()
			case .test: return L.general_testcertificate()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}
	
	/// e.g. Vaccinatiedatum etc.
	public var localizedDateLabel: String? {
		switch self {
			case .recovery: return L.generalRecoverydate()
			case .vaccination: return L.generalVaccinationdate()
			case .test: return L.generalTestdate()
			case .vaccinationassessment: return nil // not localized.
		}
	}
	
	/// e.g. "Internationaal vaccinatiebewijs"
	public var localizedProofInternational0G: String {
		switch self {
			case .recovery: return L.general_recoverycertificate_0G()
			case .vaccination: return L.general_vaccinationcertificate_0G()
			case .test: return L.general_testcertificate_0G()
			case .vaccinationassessment: return localizedProof
		}
	}

	/// There is a particular order to sort these onscreen
	public var customSortIndex: Double {
		switch self {
			case .vaccination: return 0
			case .recovery: return 1
			case .vaccinationassessment: return 2
			case .test: return 3
		}
	}
}
