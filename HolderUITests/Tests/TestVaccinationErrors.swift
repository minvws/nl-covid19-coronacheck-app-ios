/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccinationErrors: BaseTest {
	
	func test_vacP2SameDate() {
		let person = TestData.vacP2SameDate
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP1J1SameDate() {
		let person = TestData.vacP1J1SameDate
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP1M1SameDate() {
		let person = TestData.vacP1M1SameDate
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2EmptyFirstName() {
		let person = TestData.vacP2EmptyFirstName
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2EmptyLastName() {
		let person = TestData.vacP2EmptyLastName
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2BirthdateXXXX() {
		let person = TestData.vacP2BirthdateXXXX
		addVaccinationCertificate(for: person)
		
		assertNoVaccinationsAvailable()
		assertNoCertificateRetrieved()
	}
	
	func test_vacP2BirthdateXX01() {
		let person = TestData.vacP2BirthdateXX01
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2BirthdateJAN01() {
		let person = TestData.vacP2BirthdateJAN01
		addVaccinationCertificate(for: person)
		
		assertSomethingWentWrong()
		assertNoCertificateRetrieved()
	}
	
	func test_vacP2Birthdate0101() {
		let person = TestData.vacP2Birthdate0101
		addVaccinationCertificate(for: person)
		
		assertNoVaccinationsAvailable()
		assertNoCertificateRetrieved()
	}
}
