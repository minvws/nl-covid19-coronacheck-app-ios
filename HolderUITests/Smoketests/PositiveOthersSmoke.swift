/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveOthersSmoke: BaseTest {
	
	// MARK: Positive tests - breathalyzer
	
	func test_posBreathalyzer() {
		addRecoveryCertificate(for: TestData.posBreathalyzer.bsn)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Positive tests - AGOB
	
	func test_posAgob() {
		let person = TestData.posAgob
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posAgobP1() {
		let person = TestData.posAgobP1
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posAgobP2() {
		let person = TestData.posAgobP2
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	// MARK: Positive tests - older than a year
	
	func test_posOldPcr() {
		addRecoveryCertificate(for: TestData.posOldPcr.bsn)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
	}
	
	func test_posOldRat() {
		addRecoveryCertificate(for: TestData.posOldRat.bsn)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
	}
}
