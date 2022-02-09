/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccinationPremature: BaseTest {
	
	func test_vacP1Premature() {
		addVaccinationCertificate(for: TestData.vacP1Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP2Premature() {
		addVaccinationCertificate(for: TestData.vacP2Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP1P1Premature() {
		addVaccinationCertificate(for: TestData.vacP1P1Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacJ1Premature() {
		addVaccinationCertificate(for: TestData.vacJ1Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacM2Premature() {
		addVaccinationCertificate(for: TestData.vacM2Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacM1M1Premature() {
		addVaccinationCertificate(for: TestData.vacM1M1Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP1M1Premature() {
		addVaccinationCertificate(for: TestData.vacP1M1Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP1PrematureM2() {
		addVaccinationCertificate(for: TestData.vacP1PrematureM2)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacJ1M1Premature() {
		addVaccinationCertificate(for: TestData.vacJ1M1Premature)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacJ1PrematureM2() {
		addVaccinationCertificate(for: TestData.vacJ1PrematureM2)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
}
