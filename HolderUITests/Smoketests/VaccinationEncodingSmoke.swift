/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationEncodingSmoke: BaseTest {
	
	func test_encodingLatinDiacritic() {
		let person = TestData.encodingLatinDiacritic
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
