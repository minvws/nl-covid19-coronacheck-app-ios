/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationFutureTest: BaseTest {
	
	func test_vacP1Future() {
		addVaccinationCertificate(for: TestData.vacP1Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP2Future() {
		addVaccinationCertificate(for: TestData.vacP2Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP1P1Future() {
		addVaccinationCertificate(for: TestData.vacP1P1Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacJ1Future() {
		addVaccinationCertificate(for: TestData.vacJ1Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacM2Future() {
		addVaccinationCertificate(for: TestData.vacM2Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacM1M1Future() {
		addVaccinationCertificate(for: TestData.vacM1M1Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP1M1Future() {
		addVaccinationCertificate(for: TestData.vacP1M1Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacP1FutureM2() {
		addVaccinationCertificate(for: TestData.vacP1FutureM2.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacJ1M1Future() {
		addVaccinationCertificate(for: TestData.vacJ1M1Future.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_vacJ1FutureM2() {
		addVaccinationCertificate(for: TestData.vacJ1FutureM2.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
}
