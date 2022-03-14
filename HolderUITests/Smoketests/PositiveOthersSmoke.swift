/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveOthersSmoke: BaseTest {
	
	// MARK: Positive tests - breathalyzer
	
	func test_posBreathalyzer() {
		addRecoveryCertificate(for: TestData.posBreathalyzer)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Positive tests - AGOB
	
	func test_posAgob() {
		let person = TestData.posAgob
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posAgobP1() {
		let person = TestData.posAgobP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posAgobP2() {
		let person = TestData.posAgobP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	// MARK: Positive tests - older than a year
	
	func test_posOldPcr() {
		addRecoveryCertificate(for: TestData.posOldPcr)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
	}
	
	func test_posOldRat() {
		addRecoveryCertificate(for: TestData.posOldRat)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
	}
}
