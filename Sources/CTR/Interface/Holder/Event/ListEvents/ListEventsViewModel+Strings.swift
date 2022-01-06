/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListEventsViewModel {

	struct Strings {

		static func somethingIsWrongBody(forEventMode mode: EventMode) -> String? {
			switch mode {
				case .vaccinationassessment:
					return L.holder_event_vaccination_assessment_wrong_body()
				case .paperflow:
					return nil
				case .recovery:
					return L.holderRecoveryWrongBody()
				case .test, .positiveTest:
					return L.holderTestresultsWrongBody()
				case .vaccination:
					return L.holderVaccinationWrongBody()
			}
		}
	}
}
