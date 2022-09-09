/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		
		static func actionTitle(forEventMode mode: EventMode) -> String {
			switch mode {
				case .paperflow:
					return L.holderDccListAction()
				case .vaccinationassessment:
					return L.holder_event_vaccination_assessment_action_title()
				default:
					return L.holderVaccinationListAction()
			}
		}
		
	}
}
