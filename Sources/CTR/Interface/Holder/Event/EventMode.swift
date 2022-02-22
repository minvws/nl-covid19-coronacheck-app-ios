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
	case vaccinationassessment

	var localized: String {
		switch self {
			case .paperflow: return L.generalPaperflow()
			case .positiveTest: return L.generalPositiveTest()
			case .recovery: return L.general_recoverycertificate()
			case .test: return L.generalTestresult()
			case .vaccination: return L.generalVaccination()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}

	var title: String {
		switch self {
			case .paperflow: return L.holder_listRemoteEvents_paperflow_title()
			default: return L.holder_listRemoteEvents_title()
		}
	}

	var alertBody: String {

		switch self {
			case .paperflow: return L.holder_dcc_alert_message()
			case .recovery, .positiveTest: return L.holder_recovery_alert_message()
			case .test: return L.holder_test_alert_message()
			case .vaccination: return L.holder_vaccination_alert_message()
			case .vaccinationassessment: return L.holder_event_vaccination_assessment_alert_message()
		}
	}

	var listMessage: String {
		switch self {
			case .paperflow: return L.holder_listRemoteEvents_paperflow_message()
			default: return L.holder_listRemoteEvents_message()
		}
	}

	func originsMismatchBody(_ errorCode: ErrorCode) -> String {
		
		switch self {
			case .paperflow: return L.holderEventOriginmismatchDccBody("\(errorCode)")
			case .positiveTest: return "" // Not applicable
			case .recovery: return L.holderEventOriginmismatchRecoveryBody("\(errorCode)")
			case .test: return L.holderEventOriginmismatchTestBody("\(errorCode)")
			case .vaccination: return L.holderEventOriginmismatchVaccinationBody("\(errorCode)")
			case .vaccinationassessment: return L.holderEventOriginmismatchVaccinationApprovalBody("\(errorCode)")
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
			case .vaccinationassessment: return .visitorPass
		}
	}
}
