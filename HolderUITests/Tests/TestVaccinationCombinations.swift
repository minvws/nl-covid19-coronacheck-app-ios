/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccinationCombinations: BaseTest {
	
	func test_vacP1J1() {
		let person = TestData.vacP1J1
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2M1() {
		let person = TestData.vacP2M1
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ2M1() {
		let person = TestData.vacJ2M1
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2PersonalStatementVacElsewhere() {
		let person = TestData.vacP2PersonalStatementVacElsewhere
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2MedicalStatementVacElsewhere() {
		let person = TestData.vacP2MedicalStatementVacElsewhere
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2PersonalStatementPriorEvent() {
		let person = TestData.vacP2PersonalStatementPriorEvent
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2MedicalStatementPriorEvent() {
		let person = TestData.vacP2MedicalStatementPriorEvent
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
