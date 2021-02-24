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

	var cryptoManagerSpy = CryptoManagerSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	override func setUp() {
		super.setUp()

		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		configSpy = ConfigurationGeneralSpy()

		sut = EnlargedQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			configuration: configSpy
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
			configuration: configSpy
		)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showValidQR, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.hideQRForCapture, "Hide QR should not be shown")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil

		// When
		sut?.checkQRValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(cryptoManagerSpy.readCredentialsCalled, "Credentials should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertTrue(holderCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired"
		)
		configSpy.testResultTTL = 10

		// When
		sut?.checkQRValidity()

		// Then
		XCTAssertTrue(cryptoManagerSpy.readCredentialsCalled, "Credentials should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertTrue(holderCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired"
		)
		let qrMessage = Data("testValidityCredentialValid".utf8)
		cryptoManagerSpy.qrMessage = qrMessage
		configSpy.testResultTTL = 50

		// When
		sut?.checkQRValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(cryptoManagerSpy.readCredentialsCalled, "Credentials should be checked")
		XCTAssertTrue(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should be checked")
		XCTAssertEqual(strongSut.qrMessage, qrMessage, "The QR Code should match")
		XCTAssertNotNil(strongSut.validityTimer, "The timer should be started")
		XCTAssertTrue(strongSut.showValidQR, "Valid QR should be shown")
	}

	/// Test the dismiss method
	func testDismiss() {

		// Given

		// When
		sut?.dismiss()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}
}
