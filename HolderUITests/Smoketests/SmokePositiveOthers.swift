/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokePositiveOthers: BaseTest {
	
	// MARK: Positive tests - breathalyzer
	
	func test_posBreathalyzer() {
		addRecoveryCertificate(for: TestData.posBreathalyzer)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Positive tests - AGOB
	
	func test_posAgob() {
		addRecoveryCertificate(for: TestData.posAgob)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posAgobP1() {
		let person = TestData.posAgobP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posAgobP2() {
		let person = TestData.posAgobP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	// MARK: Positive tests - expired
	
	func test_posExpiredPcr() {
		addRecoveryCertificate(for: TestData.posExpiredPcr)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
	}
	
	func test_posExpiredRat() {
		addRecoveryCertificate(for: TestData.posExpiredRat)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
	}
}
