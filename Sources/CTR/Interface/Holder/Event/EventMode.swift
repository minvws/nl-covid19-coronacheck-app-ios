/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum EventMode: String {

	case paperflow
	case positiveTest
	case recovery
	case test
	case vaccination

	var localized: String {
		switch self {
			case .paperflow: return L.generalPaperflow()
			case .positiveTest: return L.generalPositiveTest()
			case .recovery: return L.generalRecoverystatement()
			case .test: return L.generalTestresult()
			case .vaccination: return L.generalVaccination()
		}
	}

	var fetching: String {
		switch self {
			case .paperflow: return L.holderDccListTitle()
			case .positiveTest: return L.holderFetcheventsPositiveTestTitle()
			case .recovery: return L.holderFetcheventsRecoveryTitle()
			case .test: return L.holderFetcheventsNegativeTestTitle()
			case .vaccination: return L.holderFetcheventsVaccinationTitle()
		}
	}

	var title: String {
		switch self {
			case .paperflow: return L.holderDccListTitle()
			case .positiveTest: return L.holderPositiveTestListTitle()
			case .recovery: return L.holderRecoveryListTitle()
			case .test: return L.holderTestresultsResultsTitle()
			case .vaccination: return L.holderVaccinationListTitle()
		}
	}

	var alertBody: String {

		switch self {
			case .paperflow: return L.holderDccAlertMessage()
			case .recovery, .positiveTest: return L.holderRecoveryAlertMessage()
			case .test: return L.holderTestAlertMessage()
			case .vaccination: return L.holderVaccinationAlertMessage()
		}
	}

	var listMessage: String {
		switch self {
			case .paperflow: return L.holderDccListMessage()
			case .positiveTest: return L.holderPositiveTestListMessage()
			case .recovery: return L.holderRecoveryListMessage()
			case .test: return L.holderTestresultsResultsText()
			case .vaccination: return L.holderVaccinationListMessage()
		}
	}

	var originsMismatchBody: String {
		switch self {
			case .paperflow: return L.holderEventOriginmismatchDccBody()
			case .positiveTest: return ""
			case .recovery: return L.holderEventOriginmismatchRecoveryBody()
			case .test: return L.holderEventOriginmismatchTestBody()
			case .vaccination: return L.holderEventOriginmismatchVaccinationBody()
		}
	}
}

extension EventMode {

	var flow: ErrorCode.Flow {

		switch self {
			case .paperflow: return .hkvi
			case .positiveTest: return .positiveTest
			case .recovery: return .recovery
			case .test: return .ggdTest
			case .vaccination: return .vaccination
		}
	}
}
