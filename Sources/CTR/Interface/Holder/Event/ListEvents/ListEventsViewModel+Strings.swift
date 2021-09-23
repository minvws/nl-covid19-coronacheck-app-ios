/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct EventStrings {
	
	static func title(forEventMode mode: EventMode) -> String {
		switch mode {
			case .paperflow:
				return L.holderDccListTitle()
			case .recovery:
				return L.holderRecoveryListTitle()
			case .test:
				return L.holderTestresultsResultsTitle()
			case .vaccination:
				return L.holderVaccinationListTitle()
		}
	}

	static func alertMessage(forEventMode mode: EventMode) -> String {
		switch mode {
			case .paperflow:
				return L.holderDccAlertMessage()
			case .recovery:
				return L.holderRecoveryAlertMessage()
			case .test:
				return L.holderTestAlertMessage()
			case .vaccination:
				return L.holderVaccinationAlertMessage()
		}
	}
}

extension ListEventsViewModel {

	struct Strings {

		static func text(forEventMode mode: EventMode) -> String {
			switch mode {
				case .paperflow:
					return L.holderDccListMessage()
				case .recovery:
					return L.holderRecoveryListMessage()
				case .test:
					return L.holderTestresultsResultsText()
				case .vaccination:
					return L.holderVaccinationListMessage()
			}
		}

		static func originsMismatchBody(forEventMode mode: EventMode) -> String {
			switch mode {
				case .paperflow:
					return L.holderEventOriginmismatchDccBody()
				case .recovery:
					return L.holderEventOriginmismatchRecoveryBody()
				case .test:
					return L.holderEventOriginmismatchTestBody()
				case .vaccination:
					return L.holderEventOriginmismatchVaccinationBody()
			}
		}

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
