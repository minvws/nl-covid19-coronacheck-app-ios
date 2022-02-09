/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestPositiveOthers: BaseTest {
	
	// MARK: Positive tests before vaccinations
	
	func test_posPcrBeforeP1() {
		let person = TestData.posPcrBeforeP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 120)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 120)
	}
	
	func test_posPcrBeforeP2() {
		let person = TestData.posPcrBeforeP2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 90)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 90)
	}
	
	func test_posPcrBeforeJ1() {
		let person = TestData.posPcrBeforeJ1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validUntilOffset: person.validUntilNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 120)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 120)
	}
	
	func test_posPcrBeforeM2() {
		let person = TestData.posPcrBeforeM2
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.doseNL, validFromOffset: person.validFromNL)
		assertValidDutchRecoveryCertificate(validUntilOffset: 90)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 90)
	}
	
	// MARK: Positive tests - breathalyzer
	
	func test_posBreathalyzerP1() {
		let person = TestData.posBreathalyzerP1
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
	}
	
	// MARK: Positive tests - expired
	
	func test_posExpiredAgob() {
		let person = TestData.posExpiredAgob
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Positive tests - premature
	
	func test_posPrematurePcr() {
		let person = TestData.posPrematurePcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffset: 41, validUntilOffset: 210)
		assertInternationalCertificateIsNotYetValid(ofType: .recovery, validFromOffset: 41, validUntilOffset: 210)
	}
	
	func test_posPrematureRat() {
		let person = TestData.posPrematureRat
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffset: 41, validUntilOffset: 210)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posPrematureAgob() {
		let person = TestData.posPrematureAgob
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .recovery, validFromOffset: 41, validUntilOffset: 210)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	// MARK: Positive tests - event matching
	
	func test_posPcrDifferentFirstName() {
		let person = TestData.posPcrDifferentFirstName
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrDifferentLastName() {
		let person = TestData.posPcrDifferentLastName
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrDifferentBirthdate() {
		let person = TestData.posPcrDifferentBirthdate
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrDifferentBirthDay() {
		let person = TestData.posPcrDifferentBirthDay
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
	
	func test_posPcrDifferentBirthMonth() {
		let person = TestData.posPcrDifferentBirthMonth
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: 150)
		assertValidInternationalRecoveryCertificate(validUntilOffset: 150)
	}
}
