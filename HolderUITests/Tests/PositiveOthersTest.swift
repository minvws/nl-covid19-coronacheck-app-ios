/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveOthersTest: BaseTest {
	
	// MARK: Positive tests before vaccinations
	
	func test_posPcrBeforeP1() {
		let person = TestData.posPcrBeforeP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrBeforeP2() {
		let person = TestData.posPcrBeforeP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrBeforeJ1() {
		let person = TestData.posPcrBeforeJ1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrBeforeM2() {
		let person = TestData.posPcrBeforeM2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	// MARK: Positive tests - breathalyzer
	
	func test_posBreathalyzerP1() {
		let person = TestData.posBreathalyzerP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: person.vacOffset)
	}
	
	// MARK: Positive tests - older than a year
	
	func test_posOldAgob() {
		let person = TestData.posOldAgob
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertPositiveTestResultNotValidAnymore()
	}
	
	// MARK: Positive tests - premature
	
	func test_posPrematurePcr() {
		let person = TestData.posPrematurePcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffset: person.recFrom, validUntilOffset: person.recUntil)
		assertInternationalCertificateIsNotYetValid(ofType: .recovery, validFromOffset: person.recFrom, validUntilOffset: person.recUntil)
	}
	
	func test_posPrematureRat() {
		let person = TestData.posPrematureRat
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffset: person.recFrom, validUntilOffset: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posPrematureAgob() {
		let person = TestData.posPrematureAgob
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffset: person.recFrom, validUntilOffset: person.recUntil)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	// MARK: Positive tests - event matching
	
	func test_posPcrDifferentFirstName() {
		let person = TestData.posPcrDifferentFirstName
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrDifferentLastName() {
		let person = TestData.posPcrDifferentLastName
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrDifferentBirthdate() {
		let person = TestData.posPcrDifferentBirthdate
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrDifferentBirthDay() {
		let person = TestData.posPcrDifferentBirthDay
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_posPcrDifferentBirthMonth() {
		let person = TestData.posPcrDifferentBirthMonth
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
}
