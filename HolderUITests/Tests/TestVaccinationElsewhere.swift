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
		
		assertValidDutchVaccinationCertificate(doses: 2, validUntilOffset: 240)
		assertValidInternationalVaccinationCertificate(doses: ["2/2"])
	}
	
	func test_vacP1PersonalStatementPriorEvent() {
		let person = TestData.vacP1PersonalStatementPriorEvent
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: ["1/2"])
	}
	
	func test_vacP2PersonalStatementVacElsewhereBoth() {
		let person = TestData.vacP2PersonalStatementVacElsewhereBoth
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 2, validUntilOffset: 240)
		assertValidInternationalVaccinationCertificate(doses: ["2/2", "2/2"])
	}
	
	func test_vacP2PersonalStatementPriorEventBoth() {
		let person = TestData.vacP2PersonalStatementPriorEventBoth
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 2, validUntilOffset: 240)
		assertValidInternationalVaccinationCertificate(doses: ["1/2", "2/2"])
	}
	
	func test_vacP2PersonalStatementVacElsewhereFirst() {
		let person = TestData.vacP2PersonalStatementVacElsewhereFirst
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 3, validFromOffset: -30)
		assertValidInternationalVaccinationCertificate(doses: ["2/2", "3/3"])
	}
	
	func test_vacP2PersonalStatementPriorEventFirst() {
		let person = TestData.vacP2PersonalStatementPriorEventFirst
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 2, validUntilOffset: 240)
		assertValidInternationalVaccinationCertificate(doses: ["1/2", "2/2"])
	}
}
