/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Clcore
import Nimble

class VerifierScanViewModelTests: XCTestCase {

    /// Subject under test
    var sut: VerifierScanViewModel!

    /// The coordinator spy
	var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!

	var cryptoSpy: CryptoManagerSpy!

    override func setUp() {

        super.setUp()
        verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		cryptoSpy = CryptoManagerSpy()
		Services.use(cryptoSpy)

        sut = VerifierScanViewModel( coordinator: verifyCoordinatorDelegateSpy)
    }

    // MARK: - Tests

    func test_dismiss() {

        // Given

        // When
        sut?.dismiss()

        // Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
    }

	func test_moreInformation() {

		// Given

		// When
		sut?.didTapMoreInformationButton()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScanInstruction) == true
	}

	func test_verificationFailed_nlDCC() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_IS_NL_DCC)
		cryptoSpy.stubbedVerifyQRMessageResult = result

		// When
		sut.parseQRMessage("test_verificationFailed_nlDCC")

		// Then
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.verifierResultAlertDccTitle()
		expect(self.sut.alert?.subTitle) == L.verifierResultAlertDccMessage()
	}

	func test_verificationFailed_unknownDCC() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX)
		cryptoSpy.stubbedVerifyQRMessageResult = result

		// When
		sut.parseQRMessage("test_verificationFailed_unknownDCC")

		// Then
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.verifierResultAlertUnknownTitle()
		expect(self.sut.alert?.subTitle) == L.verifierResultAlertUnknownMessage()
	}

	func test_verificationOK() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		cryptoSpy.stubbedVerifyQRMessageResult = result

		// When
		sut.parseQRMessage("test_verificationOK")

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScanResult) == true
	}
}
