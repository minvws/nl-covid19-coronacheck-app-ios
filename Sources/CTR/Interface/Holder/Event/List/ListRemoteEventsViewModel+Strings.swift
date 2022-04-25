/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListRemoteEventsViewModel {

	struct Strings {

		static func somethingIsWrongBody(forEventMode mode: EventMode) -> String? {
			switch mode {
				case .vaccinationassessment:
					return L.holder_listRemoteEvents_somethingWrong_vaccinationAssessment_body()
				case .paperflow:
					return nil
				case .recovery:
					return L.holder_listRemoteEvents_somethingWrong_recovery_body()
				case .test:
					return L.holder_listRemoteEvents_somethingWrong_test_body()
				case .vaccination:
					return L.holder_listRemoteEvents_somethingWrong_vaccination_body()
				case .vaccinationAndPositiveTest:
					return L.holder_listRemoteEvents_somethingWrong_vaccinationAndPositiveTest_body()
			}
		}
		
		static func originsMismatchBody(errorCode: ErrorCode, forEventMode mode: EventMode) -> String {
			
			switch mode {
				case .paperflow:
					return L.holder_listRemoteEvents_originMismatch_paperProof_body("\(errorCode)")
				case .vaccinationAndPositiveTest:
					return L.holder_listRemoteEvents_originMismatch_vaccinationAndPositiveTest_body("\(errorCode)")
				case .recovery:
					return L.holder_listRemoteEvents_originMismatch_recovery_body("\(errorCode)")
				case .test:
					return L.holder_listRemoteEvents_originMismatch_test_body("\(errorCode)")
				case .vaccination:
					return L.holder_listRemoteEvents_originMismatch_vaccination_body("\(errorCode)")
				case .vaccinationassessment:
					return L.holder_listRemoteEvents_originMismatch_vaccinationAssessment_body("\(errorCode)")
			}
		}
		
		static func listMessage(forEventMode mode: EventMode) -> String {
			
			switch mode {
				case .paperflow:
					return L.holder_listRemoteEvents_paperflow_message()
				case .recovery:
					return L.holder_listRemoteEvents_recovery_message()
				case .vaccinationAndPositiveTest, .vaccination:
					return L.holder_listRemoteEvents_vaccination_message()
				case .test:
					return L.holder_listRemoteEvents_negativeTest_message()
				case .vaccinationassessment:
					return L.holder_listRemoteEvents_vaccinationAssessment_message()
			}
		}
		
		static func title(forEventMode mode: EventMode) -> String {
			switch mode {
				case .paperflow:
					return L.holder_listRemoteEvents_paperflow_title()
				default:
					return L.holder_listRemoteEvents_title()
			}
		}
		
	}
}
