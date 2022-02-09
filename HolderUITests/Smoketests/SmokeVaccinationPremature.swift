/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokeVaccinationPremature: BaseTest {
	
	func test_vacJ1Today() {
		let person = TestData.vacJ1Today
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: 0)
	}
}
