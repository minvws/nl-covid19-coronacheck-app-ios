/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokePositiveRat: BaseTest {
	
	func test_posRat() {
		let person = TestData.posRat
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP1() {
		let person = TestData.posRatP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP2() {
		let person = TestData.posRatP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP3() {
		let person = TestData.posRatP3
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatJ1() {
		let person = TestData.posRatJ1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
}
