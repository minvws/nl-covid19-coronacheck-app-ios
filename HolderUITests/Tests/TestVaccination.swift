/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccination: BaseTest {
	
	func test_vacP4() {
		let person = TestData.vacP4
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ2() {
		let person = TestData.vacJ2
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM1() {
		let person = TestData.vacM1
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertCertificateIsOnlyValidInternationally()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM2() {
		let person = TestData.vacM2
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM3() {
		let person = TestData.vacM3
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM4() {
		let person = TestData.vacM4
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM5() {
		let person = TestData.vacM5
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}