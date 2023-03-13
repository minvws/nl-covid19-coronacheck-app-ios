/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationAround18Test: BaseTest {
	
	func test_around18Is17y8mWithP2LastDose1M() {
		let person = TestData.around18Is17y8mWithP2LastDose1M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_around18Is17y10mWithP2LastDose1M() {
		let person = TestData.around18Is17y10mWithP2LastDose1M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_around18Is17y10mWithP2LastDose9M() {
		let person = TestData.around18Is17y10mWithP2LastDose9M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_around18Is18y2mWithP2LastDose3M() {
		let person = TestData.around18Is18y2mWithP2LastDose3M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_around18Is18y2mWithP2LastDose9M() {
		let person = TestData.around18Is18y2mWithP2LastDose9M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_around18Is17y8mWithJ1LastDose1M() {
		let person = TestData.around18Is17y8mWithJ1LastDose1M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_around18Is17y10mWithJ1LastDose1M() {
		let person = TestData.around18Is17y10mWithJ1LastDose1M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_around18Is17y10mWithJ1LastDose9M	() {
		let person = TestData.around18Is17y10mWithJ1LastDose9M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_around18Is18y2mWithJ1LastDose3M() {
		let person = TestData.around18Is18y2mWithJ1LastDose3M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_around18Is18y2mWithJ1LastDose9M() {
		let person = TestData.around18Is18y2mWithJ1LastDose9M
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
}
