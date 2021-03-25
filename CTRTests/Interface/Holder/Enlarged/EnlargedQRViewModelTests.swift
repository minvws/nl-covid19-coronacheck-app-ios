/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR

class EnlargedQRViewModelTests: XCTestCase {

	/// Subject under test
	var sut: EnlargedQRViewModel?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	/// The crypto manager spy
	var cryptoManagerSpy = CryptoManagerSpy()

	/// The proof manager spy
	var proofManagerSpy = ProofManagingSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	override func setUp() {
		super.setUp()

		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		sut = EnlargedQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)
	}

	// MARK: - Tests

	/// Test all the default content
	func testContent() {

		// Given

		// When
		sut = EnlargedQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showValidQR, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.hideForCapture, "Hide QR should not be shown")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil

		// When
		sut?.checkQRValidity()

		// Then
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Method should be called")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		sut?.proofValidator = ProofValidator(maxValidity: 1)

		// When
		sut?.checkQRValidity()

		// Then
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Method should be called")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		let qrMessage = Data("testValidityCredentialValid".utf8)
		cryptoManagerSpy.qrMessage = qrMessage
		sut?.proofValidator = ProofValidator(maxValidity: 40)

		// When
		sut?.checkQRValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertTrue(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should be checked")
		XCTAssertEqual(strongSut.qrMessage, qrMessage, "The QR Code should match")
		XCTAssertNotNil(strongSut.validityTimer, "The timer should be started")
		XCTAssertTrue(strongSut.showValidQR, "Valid QR should be shown")
	}

	/// Test taking a screenshot
	func testScreenshot() {

		// Given

		// When
		NotificationCenter.default.post(
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil,
			userInfo: nil
		)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.showScreenshotWarning, "Valid QR should be shown")
	}
}
