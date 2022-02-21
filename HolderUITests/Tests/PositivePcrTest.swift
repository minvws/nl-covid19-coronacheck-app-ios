/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositivePcrTest: BaseTest {
	
	func test_posPcrJ2() {
		let person = TestData.posPcrJ2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrJ3() {
		let person = TestData.posPcrJ3
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrP1J1() {
		let person = TestData.posPcrP1J1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrP2J1() {
		let person = TestData.posPcrP2J1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
}
