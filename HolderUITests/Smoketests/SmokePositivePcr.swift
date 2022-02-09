/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokePositivePcr: BaseTest {
	
	func test_posPcr() {
		addRecoveryCertificate(for: TestData.posPcr)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP1() {
		let person = TestData.posPcrP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP2() {
		let person = TestData.posPcrP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP3() {
		let person = TestData.posPcrP3
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrJ1() {
		let person = TestData.posPcrJ1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP1M1() {
		let person = TestData.posPcrP1M1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrP2M1() {
		let person = TestData.posPcrP2M1
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
