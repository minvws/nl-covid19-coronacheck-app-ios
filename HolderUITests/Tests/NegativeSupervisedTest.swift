/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class NegativeSupervisedTest: BaseTest {
	
	func test_negPcrSupervisedSelftest() {
		let person = TestData.negPcrSupervisedSelftest
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
		
		assertNoCertificateRetrieved()
	}
	
	func test_negRatSupervisedSelftest() {
		let person = TestData.negRatSupervisedSelftest
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		assertNoCertificateCouldBeCreated()
		
		assertNoCertificateRetrieved()
	}
}
