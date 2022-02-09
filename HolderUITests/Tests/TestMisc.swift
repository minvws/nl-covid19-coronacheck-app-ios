/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestMisc: BaseTest {
	
	func test_vacP1Positive() {
		let person = TestData.miscP1Positive
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_miscP2PosPcrNegPcr() {
		let person = TestData.miscP2PosPcrNegPcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -90)
	}
}
