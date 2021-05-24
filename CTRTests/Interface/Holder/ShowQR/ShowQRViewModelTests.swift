/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR

class ShowQRViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ShowQRViewModel?

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

		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)
	}

	// MARK: - Tests

	/// Test all the default content
	func testContent() throws {

		// Given

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.showValidQR, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.hideForCapture, "Hide QR should not be shown")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.stubbedReadCredentialResult = nil

		// When
		sut?.checkQRValidity()

		// Then
		XCTAssertTrue(cryptoManagerSpy.invokedReadCredential, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.invokedGenerateQRmessage, "Generate QR should not be checked")
		XCTAssertTrue(holderCoordinatorDelegateSpy.invokedNavigateBackToStart, "Method should be called")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.stubbedReadCredentialResult = CryptoAttributes(
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
		XCTAssertTrue(cryptoManagerSpy.invokedReadCredential, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.invokedGenerateQRmessage, "Generate QR should not be checked")
		XCTAssertTrue(holderCoordinatorDelegateSpy.invokedNavigateBackToStart, "Method should be called")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() throws {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.stubbedReadCredentialResult = CryptoAttributes(
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
		cryptoManagerSpy.stubbedGenerateQRmessageResult = qrMessage
		sut?.proofValidator = ProofValidator(maxValidity: 40)

		// When
		sut?.checkQRValidity()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(cryptoManagerSpy.invokedReadCredential, "Credential should be checked")
		XCTAssertTrue(cryptoManagerSpy.invokedGenerateQRmessage, "Generate QR should be checked")
		XCTAssertEqual(strongSut.qrMessage, qrMessage, "The QR Code should match")
		XCTAssertNotNil(strongSut.validityTimer, "The timer should be started")
		XCTAssertTrue(strongSut.showValidQR, "Valid QR should be shown")
	}

	/// Test taking a screenshot
	func testScreenshot() throws {

		// Given

		// When
		NotificationCenter.default.post(
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil,
			userInfo: nil
		)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.showScreenshotWarning, "Valid QR should be shown")
	}
}
