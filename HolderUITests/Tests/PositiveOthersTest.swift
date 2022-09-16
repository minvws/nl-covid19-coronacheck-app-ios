/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveOthersTest: BaseTest {
	
	// MARK: Positive tests before vaccinations
	
	func test_posPcrBeforeP1() {
		let person = TestData.posPcrBeforeP1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrBeforeP2() {
		let person = TestData.posPcrBeforeP2
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrBeforeJ1() {
		let person = TestData.posPcrBeforeJ1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrBeforeM2() {
		let person = TestData.posPcrBeforeM2
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	// MARK: Positive tests - breathalyzer
	
	func test_posBreathalyzerP1() {
		let person = TestData.posBreathalyzerP1
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertHintForOnlyInternationalCertificate()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	// MARK: Positive tests - older than a year
	
	func test_posOldAgob() {
		let person = TestData.posOldAgob
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
	}
	
	// MARK: Positive tests - premature
	
	func test_posPrematurePcr() {
		let person = TestData.posPrematurePcr
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffsetInDays: person.recFrom, validUntilOffsetInDays: person.recUntil)
		assertInternationalCertificateIsNotYetValid(ofType: .recovery, validFromOffsetInDays: person.recFrom, validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPrematureRat() {
		let person = TestData.posPrematureRat
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffsetInDays: person.recFrom, validUntilOffsetInDays: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posPrematureAgob() {
		let person = TestData.posPrematureAgob
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffsetInDays: person.recFrom, validUntilOffsetInDays: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	// MARK: Positive tests - event matching
	
	func test_posPcrDifferentFirstName() {
		let person = TestData.posPcrDifferentFirstName
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrDifferentLastName() {
		let person = TestData.posPcrDifferentLastName
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrDifferentBirthdate() {
		let person = TestData.posPcrDifferentBirthdate
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrDifferentBirthDay() {
		let person = TestData.posPcrDifferentBirthDay
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrDifferentBirthMonth() {
		let person = TestData.posPcrDifferentBirthMonth
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	// MARK: Positive tests - multiples
	
	func test_posPcr2Recent() {
		let person = TestData.posPcr2Recent
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcr2Old() {
		let person = TestData.posPcr2Old
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
