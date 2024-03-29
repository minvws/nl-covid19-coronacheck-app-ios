/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationSmoke: BaseTest {
	
	func test_vacP1() {
		let person = TestData.vacP1
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacP2() {
		let person = TestData.vacP2
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1() {
		let person = TestData.vacJ1
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
}
