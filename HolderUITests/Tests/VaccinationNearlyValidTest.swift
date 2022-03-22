/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationNearlyValidTest: BaseTest {
	
	func test_vacP2ValidTomorrow() {
		let person = TestData.vacP2ValidTomorrow
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacJ1ValidTomorrow() {
		let person = TestData.vacJ1ValidTomorrow
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacM2ValidTomorrow() {
		let person = TestData.vacM2ValidTomorrow
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacP2ValidToday() {
		let person = TestData.vacP2ValidToday
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacJ1ValidToday() {
		let person = TestData.vacJ1ValidToday
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacM2ValidToday() {
		let person = TestData.vacM2ValidToday
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
}
