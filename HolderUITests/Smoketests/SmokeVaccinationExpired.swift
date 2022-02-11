/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokeVaccinationExpired: BaseTest {
	
	func test_vacP1Expired() {
		let person = TestData.vacP1Expired
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -390)
	}
	
	func test_vacP2Expired() {
		let person = TestData.vacP2Expired
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -390)
	}
	
	func test_vacJ1Expired() {
		let person = TestData.vacJ1Expired
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -390)
	}
	
	func test_vacM1Expired() {
		let person = TestData.vacM1Expired
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -390)
	}
	
	func test_vacM2Expired() {
		let person = TestData.vacM2Expired
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -390)
	}
}
