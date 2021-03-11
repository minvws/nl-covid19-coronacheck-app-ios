/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR

class DashboardViewModelTests: XCTestCase {

	/// Subject under test
	var sut: HolderDashboardViewModel?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	var cryptoManagerSpy = CryptoManagerSpy()

	var proofManagerSpy = ProofManagingSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	override func setUp() {
		super.setUp()

		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		sut = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)
	}

	// MARK: - Tests

	/// Test the appointment card tapped
	func testCardTappedAppointment() {

		// Given

		// When
		sut?.cardTapped(.appointment)

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToAppointmentCalled, "Coordinator delegate method should be called")
	}

	/// Test the createt card tapped
	func testCardTappedCreate() {

		// Given

		// When
		sut?.cardTapped(.create)

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToChooseProviderCalled, "Coordinator delegate method should be called")
	}

	/// Test all the default content
	func testContent() {

		// Given
		proofManagerSpy.birthDate = Date()

		// When
		sut = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)

		// Then
		XCTAssertEqual(sut?.title, .holderDashboardTitle, "Title should match")
		XCTAssertEqual(sut?.message, .holderDashboardIntro, "Message should match")
		XCTAssertNil(sut?.qrSubTitle, "Subtitle should be nil")
		XCTAssertEqual(sut?.qrTitle, .holderDashboardQRTitle, "QR Title should match")
		XCTAssertEqual(sut?.expiredTitle, .holderDashboardQRExpired, "QR Expired title should match")
		XCTAssertNotNil(sut?.appointmentCard, "The appointment card should not be nil")
		XCTAssertNotNil(sut?.createCard, "The create card should not be nil")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showValidQR, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.showExpiredQR, "Expired QR should not be shown")
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
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertNil(strongSut.qrMessage, "There should be no QR code")
		XCTAssertFalse(strongSut.showValidQR, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.showExpiredQR, "Expired QR should not be shown")
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
			testType: "testValidityCredentialExpired"
		)
		sut?.proofValidator = ProofValidator(maxValidity: 1)

		// When
		sut?.checkQRValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertNil(strongSut.qrMessage, "There should be no QR code")
		XCTAssertNil(strongSut.validityTimer, "The timer should be nil")
		XCTAssertFalse(strongSut.showValidQR, "Valid QR should not be shown")
		XCTAssertTrue(strongSut.showExpiredQR, "Expired QR should be shown")
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
			testType: "testValidityCredentialExpired"
		)
		let qrMessage = Data("testValidityCredentialValid".utf8)
		cryptoManagerSpy.qrMessage = qrMessage
		sut?.proofValidator = ProofValidator(maxValidity: 1)
		proofManagerSpy.birthDate = Date()

		// When
		sut?.checkQRValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertTrue(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should be checked")
		XCTAssertNotNil(strongSut.qrSubTitle, "Subtitle should be nil")
		XCTAssertEqual(strongSut.qrMessage, qrMessage, "The QR Code should match")
		XCTAssertNotNil(strongSut.validityTimer, "The timer should be started")
		XCTAssertTrue(strongSut.showValidQR, "Valid QR should be shown")
		XCTAssertFalse(strongSut.showExpiredQR, "Expired QR should not be shown")
	}

	/// Test the navigat to enlarged QR scene
	func testNavigateToEnlargedQR() {

		// Given

		// When
		sut?.navigateToEnlargedQR()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToEnlargedQRCalled, "Delegate method should be called")
	}

	func testCloseExpiredRQ() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired"
		)
		sut?.proofValidator = ProofValidator(maxValidity: 1)
		sut?.checkQRValidity()

		// When
		sut?.closeExpiredRQ()

		// Then
		XCTAssertTrue(cryptoManagerSpy.removeCredentialCalled, "Credential should be removed")
		XCTAssertNil(cryptoManagerSpy.crypoAttributes)
	}
}
