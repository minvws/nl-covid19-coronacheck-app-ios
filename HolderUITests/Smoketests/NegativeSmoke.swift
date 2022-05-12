/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class NegativeSmoke: BaseTest {
	
	// MARK: Negative tests (and combinations)
	
	func test_negPcr() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
		assertInternationalTestQRDetails(for: person, testType: .pcr)
	}
	
	func test_negRat() {
		let person = TestData.negRat
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .rat)
		assertInternationalTestQRDetails(for: person, testType: .rat)
	}
	
	func test_negAgob() {
		addTestCertificateFromGGD(for: TestData.negAgob)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
	
	// MARK: Negative tests - 30 days old
	
	func test_negOldPcr() {
		addTestCertificateFromGGD(for: TestData.negOldPcr)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated()
	}
	
	// MARK: Negative tests - premature
	
	func test_negPrematurePcr() {
		let person = TestData.negPrematurePcr
		addTestCertificateFromGGD(for: TestData.negPrematurePcr)
		addRetrievedCertificateToApp()
		
		assertDutchCertificateIsNotYetValid(ofType: .test, validFromOffsetInDays: person.testFrom)
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
}
