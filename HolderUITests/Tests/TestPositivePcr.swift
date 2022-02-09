/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestPositivePcr: BaseTest {
	
	func test_posPcrJ2() {
		let person = TestData.posPcrJ2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrJ3() {
		let person = TestData.posPcrJ3
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP1J1() {
		let person = TestData.posPcrP1J1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP2J1() {
		let person = TestData.posPcrP2J1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
}
