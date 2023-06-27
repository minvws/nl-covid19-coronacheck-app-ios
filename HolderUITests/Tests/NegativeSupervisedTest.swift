/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class NegativeSupervisedTest: BaseTest {
	
	func test_negPcrSupervisedSelftest() {
		let person = TestData.negPcrSupervisedSelftest
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated(error: "i 480 000 0512")
	}
	
	func test_negRatSupervisedSelftest() {
		let person = TestData.negRatSupervisedSelftest
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertNoCertificateCouldBeCreated(error: "i 480 000 0512")
	}
}
