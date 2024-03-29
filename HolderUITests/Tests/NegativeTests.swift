/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class NegativeTests: BaseTest {
	
	// MARK: Negative tests (and combinations)
	
	func test_negPcrP1() {
		let person = TestData.negPcrP1
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_negRatP1() {
		let person = TestData.negRatP1
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .rat)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
	}
	
	func test_negAgobP1() {
		let person = TestData.negAgobP1
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated(error: "i 480 000 0512")
	}
	
	// MARK: Negative tests - 30 days old
	
	func test_negOldRat() {
		addTestCertificateFromGGD(for: TestData.negOldRat.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	func test_negOldAgob() {
		addTestCertificateFromGGD(for: TestData.negOldAgob.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Negative tests - premature
	
	func test_negPrematureRat() {
		let person = TestData.negPrematureRat
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
	
	func test_negPrematureAgob() {
		let person = TestData.negPrematureAgob
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
	}
	
	// MARK: Negative tests - event matching
	
	func test_negPcrDifferentFirstName() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentFirstName.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentLastName() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentLastName.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentBirthdate() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentBirthdate.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentBirthDay() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentBirthDay.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negPcrDifferentBirthMonth() {
		addTestCertificateFromGGD(for: TestData.negPcrDifferentBirthMonth.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
}
