/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationOlderThanOneYearSmoke: BaseTest {
	
	func test_vacP1Old() {
		let person = TestData.vacP1Old
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP2Old() {
		let person = TestData.vacP2Old
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacJ1Old() {
		let person = TestData.vacJ1Old
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacM1Old() {
		let person = TestData.vacM1Old
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacM2Old() {
		let person = TestData.vacM2Old
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
}
