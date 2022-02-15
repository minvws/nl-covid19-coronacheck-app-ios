/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestAlmost18: BaseTest {
	
	func test_almost18Is17y8mWithP2LastDose1M() {
		let person = TestData.almost18Is17y8mWithP2LastDose1M
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_almost18Is17y10mWithP2LastDose1M() {
		let person = TestData.almost18Is17y10mWithP2LastDose1M
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_almost18Is17y10mWithP2LastDose9M() {
		let person = TestData.almost18Is17y10mWithP2LastDose9M
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilDate: person.vacUntilDate)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
	}
	
	func test_almost18Is17y8mWithJ1LastDose1M() {
		let person = TestData.almost18Is17y8mWithJ1LastDose1M
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_almost18Is17y10mWithJ1LastDose1M() {
		let person = TestData.almost18Is17y10mWithJ1LastDose1M
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_almost18Is17y10mWithJ1LastDose9M	() {
		let person = TestData.almost18Is17y10mWithJ1LastDose9M
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilDate: person.vacUntilDate)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
	}
}
