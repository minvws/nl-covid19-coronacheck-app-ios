/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokeVaccinationNearlyValid: BaseTest {
	
	func test_vacP2DatedToday() {
		let person = TestData.vacP2DatedToday
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffset: person.vacFrom)
		assertInternationalCertificateIsNotYetValid(ofType: .vaccination, validFromOffset: person.vacFrom)
	}
	
	func test_vacJ1DatedToday() {
		let person = TestData.vacJ1DatedToday
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffset: person.vacFrom)
		assertInternationalCertificateIsNotYetValid(ofType: .vaccination, validFromOffset: person.vacFrom)
	}
	
	func test_vacM2DatedToday() {
		let person = TestData.vacM2DatedToday
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .vaccination, validFromOffset: person.vacFrom)
		assertInternationalCertificateIsNotYetValid(ofType: .vaccination, validFromOffset: person.vacFrom)
	}
}
