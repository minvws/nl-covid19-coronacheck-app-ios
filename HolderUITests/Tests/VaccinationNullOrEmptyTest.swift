/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationNullOrEmptyTest: BaseTest {
	
	func test_vacP1NullPersonalStatement() {
		let person = TestData.vacP1NullPersonalStatement
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1NullMedicalStatement() {
		let person = TestData.vacP1NullMedicalStatement
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1NullFirstName() {
		let person = TestData.vacP1NullFirstName
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1NullLastName() {
		let person = TestData.vacP1NullLastName
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1NullBirthdate() {
		let person = TestData.vacP1NullBirthdate
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1EmptyPersonalStatement() {
		let person = TestData.vacP1EmptyPersonalStatement
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1EmptyMedicalStatement() {
		let person = TestData.vacP1EmptyMedicalStatement
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1EmptyFirstName() {
		let person = TestData.vacP1EmptyFirstName
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1EmptyLastName() {
		let person = TestData.vacP1EmptyLastName
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP1EmptyBirthdate() {
		let person = TestData.vacP1EmptyBirthdate
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
}
