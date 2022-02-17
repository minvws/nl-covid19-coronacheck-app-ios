/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccinationElsewhere: BaseTest {
	
	func test_vacP1PersonalStatementVacElsewhere() {
		let person = TestData.vacP1PersonalStatementVacElsewhere
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 1, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: ["1/1"])
	}
	
	func test_vacP1PersonalStatementPriorEvent() {
		let person = TestData.vacP1PersonalStatementPriorEvent
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2PersonalStatementVacElsewhereBoth() {
		let person = TestData.vacP2PersonalStatementVacElsewhereBoth
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: -30)
		assertValidInternationalVaccinationCertificate(doses: ["1/1", "2/1"])
	}
	
	func test_vacP2PersonalStatementPriorEventBoth() {
		let person = TestData.vacP2PersonalStatementPriorEventBoth
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2PersonalStatementVacElsewhereFirst() {
		let person = TestData.vacP2PersonalStatementVacElsewhereFirst
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 2, validFromOffset: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: ["1/1", "2/1"])
	}
	
	func test_vacP2PersonalStatementPriorEventFirst() {
		let person = TestData.vacP2PersonalStatementPriorEventFirst
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}