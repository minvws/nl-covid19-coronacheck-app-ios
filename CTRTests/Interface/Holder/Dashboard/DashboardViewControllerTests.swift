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
			configuration: configSpy
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
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.title, .holderDashboardTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .holderDashboardIntro, "Message should match")
		XCTAssertEqual(strongSut.sceneView.qrView.title, .holderDashboardQRTitle, "QR Title should match")
		XCTAssertEqual(strongSut.sceneView.expiredQRView.title, .holderDashboardQRExpired, "QR Expired title should match")
		XCTAssertTrue(strongSut.sceneView.qrView.isHidden, "Valid QR should not be shown")
		XCTAssertNil(strongSut.sceneView.qrView.imageView.image, "There should be no image")
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
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired"
		)
		let qrMessage = Data("testValidityCredentialValid".utf8)
		cryptoManagerSpy.qrMessage = qrMessage
		configSpy.testResultTTL = 50
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() {

		// Given
		setupValidCredential()
		proofManagerSpy.birthDate = Date()
		loadView()

		// When
		sut?.checkValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.qrView.isHidden, "Valid QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.qrView.subTitle, "SubTitle should not be nil")
		XCTAssertNotNil(strongSut.sceneView.qrView.imageView.image, "There should be an image")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
	}

	/// Test the validity of the credential with valid credential without a birthdate
	func testValidityCredentialValidNoBirthDate() {

		// Given
		setupValidCredential()
		proofManagerSpy.birthDate = nil
		loadView()

		// When
		sut?.checkValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.qrView.isHidden, "Valid QR should be shown")
		XCTAssertNil(strongSut.sceneView.qrView.subTitle, "SubTitle should be nil")
		XCTAssertNotNil(strongSut.sceneView.qrView.imageView.image, "There should be an image")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
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
		loadView()

		// When
		sut?.checkValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.sceneView.qrView.isHidden, "Valid QR should not be shown")
		XCTAssertNil(strongSut.sceneView.qrView.imageView.image, "There should be no image")
		XCTAssertFalse(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should be shown")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil
		loadView()

		// When
		sut?.checkValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.sceneView.qrView.isHidden, "Valid QR should not be shown")
		XCTAssertNil(strongSut.sceneView.qrView.imageView.image, "There should be no image")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidTapQR() {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		sut?.showLargeQR()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.qrView.isHidden, "Valid QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.qrView.imageView.image, "There should be an image")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToEnlargedQRCalled, "Delegate method should be called")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidWithScreenCapture() {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		viewModel?.hideQRForCapture = true

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.qrView.isHidden, "Valid QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.qrView.imageView.image, "There should be an image")
		XCTAssertTrue(strongSut.sceneView.qrView.imageView.isHidden, "The image should be hidden")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidShowLargeQRWithScreenCapture() {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()
		viewModel?.hideQRForCapture = true

		// When
		sut?.showLargeQR()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.qrView.isHidden, "Valid QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.qrView.imageView.image, "There should be an image")
		XCTAssertTrue(strongSut.sceneView.qrView.imageView.isHidden, "The image should be hidden")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
		XCTAssertFalse(holderCoordinatorDelegateSpy.navigateToEnlargedQRCalled, "Delegate method should not be called")
	}

	/// Test the security features
	func testSecurityFeaturesAnimation() {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.qrView.securityView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.qrView.isHidden, "Valid QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.qrView.imageView.image, "There should be an image")
		XCTAssertTrue(strongSut.sceneView.expiredQRView.isHidden, "Expired QR should not be shown")
		XCTAssertEqual(strongSut.sceneView.qrView.securityView.currentAnimation, .cyclistRightToLeft, "Animation should match")
	}

	func testCloseExpiredRQ() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired"
		)
		configSpy.testResultTTL = 10
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.expiredQRView.closeButtonTapped()

		// Then
		XCTAssertTrue(cryptoManagerSpy.removeCredentialCalled, "Credential should be removed")
		XCTAssertNil(cryptoManagerSpy.crypoAttributes)
	}
}
