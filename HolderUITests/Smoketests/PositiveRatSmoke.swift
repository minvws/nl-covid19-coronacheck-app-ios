/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveRatSmoke: BaseTest {
	
	func test_posRat() {
		let person = TestData.posRat
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP1() {
		let person = TestData.posRatP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP2() {
		let person = TestData.posRatP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP3() {
		let person = TestData.posRatP3
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatJ1() {
		let person = TestData.posRatJ1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
}
