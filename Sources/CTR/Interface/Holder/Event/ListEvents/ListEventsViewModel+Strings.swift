/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListEventsViewModel {

	struct Strings {

		static func somethingIsWrongBody(forEventMode mode: EventMode, dataSource: [EventDataTuple]) -> String {
			switch mode {
				case .paperflow:

					if let credentialData = dataSource.first?.event.dccEvent?.credential.data(using: .utf8),
					   let euCredentialAttributes = Services.cryptoManager.readEuCredentials(credentialData) {

						if euCredentialAttributes.digitalCovidCertificate.vaccinations?.first != nil {
							return L.holderVaccinationWrongBody()
						} else if euCredentialAttributes.digitalCovidCertificate.recoveries?.first != nil {
							return L.holderRecoveryWrongBody()
						} else if euCredentialAttributes.digitalCovidCertificate.tests?.first != nil {
							return L.holderTestresultsWrongBody()
						}
					}
					return ""

				case .recovery:
					return L.holderRecoveryWrongBody()
				case .test:
					return L.holderTestresultsWrongBody()
				case .vaccination:
					return L.holderVaccinationWrongBody()
			}
		}
	}
}
