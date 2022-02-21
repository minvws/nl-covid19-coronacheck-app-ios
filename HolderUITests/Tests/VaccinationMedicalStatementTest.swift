/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationMedicalStatementTest: BaseTest {
	
	func test_vacP1MedicalStatement() {
		let person = TestData.vacP1MedicalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2MedicalStatement() {
		let person = TestData.vacP2MedicalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM1MedicalStatement() {
		let person = TestData.vacM1MedicalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM3MedicalStatement() {
		let person = TestData.vacM3MedicalStatement
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
