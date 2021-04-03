/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class DashboardViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: HolderDashboardViewController?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	var cryptoManagerSpy = CryptoManagerSpy()

	var proofManagerSpy = ProofManagingSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	/// The view model
	var viewModel: HolderDashboardViewModel?

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		viewModel = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)
		sut = HolderDashboardViewController(viewModel: viewModel!)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		if let sut = sut {
			window.addSubview(sut.view)
			RunLoop.current.run(until: Date())
		}
	}

	// MARK: - Tests

	/// Test all the default content
	func testContent() throws {

		// Given

		// When
		loadView()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.title, .holderDashboardTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .holderDashboardIntro, "Message should match")
		XCTAssertEqual(strongSut.sceneView.expiredQRView.title, .holderDashboardQRExpired, "QR Expired title should match")
		XCTAssertTrue(strongSut.sceneView.qrCardView.isHidden, "Valid QR should not be shown")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
	}

	/// Test tapping on the appointment card
	func testCardTappedAppointment() {

		// Given
		loadView()

		// When
		sut?.sceneView.appointmentCard.primaryButtonTapped()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToAppointmentCalled, "Coordinator delegate method should be called")
	}

	/// Test tapping on the create qr card
	func testCardTappedCreate() {

		// Given
		loadView()

		// When
		sut?.sceneView.createCard.primaryButtonTapped()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToChooseProviderCalled, "Coordinator delegate method should be called")
	}

	/// Helper method to setup valid credential
	func setupValidCredential() {

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
		viewModel?.proofValidator = ProofValidator(maxValidity: 1)
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() throws {

		// Given
		setupValidCredential()
		loadView()

		// When
		sut?.checkValidity()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.sceneView.qrCardView.isHidden, "Valid QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.qrCardView.message, "SubTitle should not be nil")
		XCTAssertNotNil(strongSut.sceneView.qrCardView.title, "Title should not be nil")
		XCTAssertNotNil(strongSut.sceneView.qrCardView.time, "Time should not be nil")
		XCTAssertNotNil(strongSut.sceneView.qrCardView.identity, "Identity should not be nil")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
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
		viewModel?.proofValidator = ProofValidator(maxValidity: 1)
		loadView()

		// When
		sut?.checkValidity()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.qrCardView.isHidden, "Valid QR should not be shown")
		XCTAssertFalse(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should be shown")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() throws {

		// Given
		cryptoManagerSpy.crypoAttributes = nil
		loadView()

		// When
		sut?.checkValidity()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.qrCardView.isHidden, "Valid QR should not be shown")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidTapQR() throws {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.qrCardView.primaryButtonTapped()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.sceneView.qrCardView.isHidden, "QR card should be shown")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToEnlargedQRCalled, "Delegate method should be called")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidWithScreenCapture() throws {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		viewModel?.hideForCapture = true

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.qrCardView.isHidden, "QR Card should be hidden")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
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
		viewModel?.proofValidator = ProofValidator(maxValidity: 1)
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.expiredQRView.closeButtonTapped()

		// Then
		XCTAssertTrue(cryptoManagerSpy.removeCredentialCalled, "Credential should be removed")
		XCTAssertNil(cryptoManagerSpy.crypoAttributes)
	}
}
