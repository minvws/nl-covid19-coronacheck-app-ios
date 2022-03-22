/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class NegativeSupervisedTest: BaseTest {
	
	override func setUpWithError() throws {
		self.disclosureMode = DisclosureMode.mode1GWith3G
		
		try super.setUpWithError()
	}
	
	func test_negPcrSupervisedSelftest() {
		let person = TestData.negPcrSupervisedSelftest
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate(validUntilOffset: 0)
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
	
	func test_negRatSupervisedSelftest() {
		let person = TestData.negRatSupervisedSelftest
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate(validUntilOffset: 0)
		assertCertificateIsNotValidInternationally(ofType: .test)
	}
}
