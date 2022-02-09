/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccinationPersonalStatement: BaseTest {
	
	func test_vacP2PersonalStatement() {
		let person = TestData.vacP2PersonalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1PersonalStatement() {
		let person = TestData.vacJ1PersonalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM1PersonalStatement() {
		let person = TestData.vacM1PersonalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM3PersonalStatement() {
		let person = TestData.vacM3PersonalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
