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
	func testContent() throws {

		// Given

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
		XCTAssertNil(sut?.qrCard, "QR card should be nil")
		XCTAssertEqual(sut?.expiredTitle, .holderDashboardQRExpired, "QR Expired title should match")
		XCTAssertNotNil(sut?.appointmentCard, "The appointment card should not be nil")
		XCTAssertNotNil(sut?.createCard, "The create card should not be nil")
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.showExpiredQR, "Expired QR should not be shown")
		XCTAssertFalse(strongSut.hideForCapture, "Hide QR should not be shown")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() throws {

		// Given
		cryptoManagerSpy.crypoAttributes = nil

		// When
		sut?.checkQRValidity()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertNil(strongSut.qrCard, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.showExpiredQR, "Expired QR should not be shown")
		XCTAssertEqual(strongSut.createCard.title, .holderDashboardCreateTitle, "The title of the create card should match")
		XCTAssertEqual(strongSut.createCard.actionTitle, .holderDashboardCreateAction, "The action title of the create card should match")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() throws {

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
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertFalse(cryptoManagerSpy.generateQRmessageCalled, "Generate QR should not be checked")
		XCTAssertNil(strongSut.validityTimer, "The timer should be nil")
		XCTAssertNil(strongSut.qrCard, "Valid QR should not be shown")
		XCTAssertTrue(strongSut.showExpiredQR, "Expired QR should be shown")
		XCTAssertEqual(strongSut.createCard.title, .holderDashboardCreateTitle, "The title of the create card should match")
		XCTAssertEqual(strongSut.createCard.actionTitle, .holderDashboardCreateAction, "The action title of the create card should match")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() throws {

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
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(cryptoManagerSpy.readCredentialCalled, "Credential should be checked")
		XCTAssertNotNil(strongSut.qrCard, "Subtitle should be nil")
		XCTAssertNotNil(strongSut.validityTimer, "The timer should be started")
		XCTAssertFalse(strongSut.showExpiredQR, "Expired QR should not be shown")
		XCTAssertEqual(strongSut.createCard.title, .holderDashboardChangeTitle, "The title of the create card should match")
		XCTAssertEqual(strongSut.createCard.actionTitle, .holderDashboardChangeAction, "The action title of the create card should match")
	}

	/// Test the navigat to enlarged QR scene
	func testNavigateToEnlargedQR() {

		// Given

		// When
		sut?.cardTapped(.qrcode)

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
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
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
