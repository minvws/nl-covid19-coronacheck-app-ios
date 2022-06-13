/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class NegativeTests: BaseTest {
	
	// MARK: Negative tests (and combinations)
	
	func test_negPcrP1() {
		let person = TestData.negPcrP1
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidDutchTestCertificate()
		assertNoValidDutchCertificate(ofType: .vaccination)
		
		assertValidInternationalTestCertificate(testType: .pcr)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_negRatP1() {
		let person = TestData.negRatP1
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidDutchTestCertificate()
		assertNoValidDutchCertificate(ofType: .vaccination)
		
		assertValidInternationalTestCertificate(testType: .rat)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_negAgobP1() {
		let person = TestData.negAgobP1
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreatedIn0G()
		
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidDutchTestCertificate()
		assertNoValidDutchCertificate(ofType: .vaccination)
		
		assertCertificateIsNotValidInternationally(ofType: .test)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	// MARK: Negative tests - 30 days old
	
	func test_negOldRat() {
		addTestCertificateFromGGD(for: TestData.negOldRat)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_negOldAgob() {
		addTestCertificateFromGGD(for: TestData.negOldAgob)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Negative tests - premature
	
	func test_negPrematureRat() {
		let person = TestData.negPrematureRat
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .test, validFromOffsetInDays: person.testFrom)
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
	
	func test_negPrematureAgob() {
		let person = TestData.negPrematureAgob
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .test, validFromOffsetInDays: person.testFrom)
	}
	
	// MARK: Negative tests - event matching
	
	func test_negPcrDifferentFirstName() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentFirstName)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentLastName() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentLastName)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentBirthdate() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentBirthdate)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentBirthDay() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentBirthDay)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentBirthMonth() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentBirthMonth)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
}
