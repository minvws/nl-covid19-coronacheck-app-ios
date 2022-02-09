/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestNegative: BaseTest {
	
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
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
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
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
	}
	
	func test_negAgobP1() {
		let person = TestData.negAgobP1
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidDutchTestCertificate()
		assertNoValidDutchCertificate(ofType: .vaccination)
		
		assertCertificateIsNotValidInternationally(ofType: .test)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, dateOffset: -60)
	}
	
	// MARK: Negative tests - expired
	
	func test_negExpiredRat() {
		addTestCertificateFromGGD(for: TestData.negExpiredRat)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_negExpiredAgob() {
		addTestCertificateFromGGD(for: TestData.negExpiredAgob)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Negative tests - premature
	
	func test_negPrematureRat() {
		addTestCertificateFromGGD(for: TestData.negPrematureRat)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .test, validFromOffset: 30)
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
	
	func test_negPrematureAgob() {
		addTestCertificateFromGGD(for: TestData.negPrematureAgob)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .test, validFromOffset: 30)
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
