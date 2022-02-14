/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokeNegative: BaseTest {
	
	// MARK: Negative tests (and combinations)
	
	func test_negPcr() {
		addTestCertificateFromGGD(for: TestData.negPcr)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_negRat() {
		addTestCertificateFromGGD(for: TestData.negRat)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .rat)
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
		
		assertDutchCertificateIsNotYetValid(ofType: .test, validFromOffset: person.testFrom)
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
}
