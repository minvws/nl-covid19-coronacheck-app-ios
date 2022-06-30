/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationNearlyValidSmoke: BaseTest {
	
	func test_vacP2DatedToday() {
		let person = TestData.vacP2DatedToday
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacJ1DatedToday() {
		let person = TestData.vacJ1DatedToday
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_vacM2DatedToday() {
		let person = TestData.vacM2DatedToday
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
}
