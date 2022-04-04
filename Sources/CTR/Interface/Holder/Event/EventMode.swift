/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum EventMode: String {

	case paperflow
	case vaccinationAndPositiveTest = "positiveTest"  // rawValue positiveTest for backwards compatibility with CoreData
	case recovery
	case test
	case vaccination
	case vaccinationassessment

	var localized: String {
		switch self {
			case .paperflow: return L.generalPaperflow()
			case .vaccinationAndPositiveTest: return L.generalPositiveTest()
			case .recovery: return L.general_recoverycertificate()
			case .test: return L.generalTestresult()
			case .vaccination: return L.general_vaccination()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}

	var alertBody: String {

		switch self {
			case .paperflow: return L.holder_dcc_alert_message()
			case .recovery, .vaccinationAndPositiveTest: return L.holder_recovery_alert_message()
			case .test: return L.holder_test_alert_message()
			case .vaccination: return L.holder_vaccination_alert_message()
			case .vaccinationassessment: return L.holder_event_vaccination_assessment_alert_message()
		}
	}
}

// MARK: - ErrorCode Flow -

extension EventMode {

	var flow: ErrorCode.Flow {

		switch self {
			case .paperflow: return .hkvi
			case .vaccinationAndPositiveTest: return .vaccinationAndPositiveTest
			case .recovery: return .recovery
			case .test: return .ggdTest
			case .vaccination: return .vaccination
			case .vaccinationassessment: return .visitorPass
		}
	}
}

// MARK: - Query Filter -

extension EventMode {
	
	/// Translate EventMode into a filter string that can be passed to the network as a query string
	var queryFilterValue: String? {
		switch self {
			case .vaccinationAndPositiveTest: return "positivetest"
			case .recovery: return "positivetest"
			case .test: return "negativetest"
			case .vaccination: return "vaccination"
			default: return nil
		}
	}
	
	/// Translate EventMode into a scope string that can be passed to the network as a query string
	///
	/// The 'recovery' scope typically returns the most recent positive test result for a user, to maximise the validity of the recovery certificate. If the test returned is a PCR test,
	/// the user will receive a CTB and a DCC from the same date. However, if the test returned is an antigen test, the api will also return the second most recent test if that one is a PCR test.
	/// In that case, the user will get a DCC based on the older PCR test, and a CTB based on the newer Antigen test
	var queryScopeValue: String? {
		switch self {
			case .vaccinationAndPositiveTest: return "firstepisode"
			case .recovery: return "recovery"
			default: return nil
		}
	}
	
	var queryFilter: [String: String?] {
		return [
			Keys.filter.rawValue: queryFilterValue,
			Keys.scope.rawValue: queryScopeValue
		]
	}
	
	enum Keys: String {
		case filter
		case scope
	}
}
