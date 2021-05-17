/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR

class EnlargedQRViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: EnlargedQRViewController?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	/// The crypto manager spy
	var cryptoManagerSpy = CryptoManagerSpy()

	/// The proof manager spy
	var proofManagerSpy = ProofManagingSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	/// The view model
	var viewModel: EnlargedQRViewModel?

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		viewModel = EnlargedQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)
		sut = EnlargedQRViewController(viewModel: viewModel!)
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
		XCTAssertEqual(strongSut.title, .holderEnlargedTitle, "Title should match")
		XCTAssertFalse(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should not be shown")
		XCTAssertNil(strongSut.sceneView.largeQRimageView.image, "There should be no image")
	}

	/// Helper method to setup valid credential
	func setupValidCredential() {

		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
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
		XCTAssertFalse(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.largeQRimageView.image, "There should be image")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
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
		XCTAssertTrue(holderCoordinatorDelegateSpy.invokedNavigateBackToStart, "Method should be called")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil
		loadView()

		// When
		sut?.checkValidity()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.invokedNavigateBackToStart, "Method should be called")
	}

	/// Test the validity of the credential with valid credential while screencapturing
	func testValidityCredentialValidWithScreenCapture() throws {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		viewModel?.hideForCapture = true

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should not be shown")
		XCTAssertNotNil(strongSut.sceneView.largeQRimageView.image, "There should be image")
	}

	/// Test the security features
	func testSecurityFeaturesAnimation() throws {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.securityView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.largeQRimageView.image, "There should be image")
		XCTAssertEqual(strongSut.sceneView.securityView.currentAnimation, .cyclistRightToLeft, "Animation should match")
	}

	/// Test showing the alert dialog for screen shots
	func testAlertDialog() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		NotificationCenter.default.post(
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil,
			userInfo: nil
		)

		// Then
		alertVerifier.verify(
			title: .holderEnlargedScreenshotTitle,
			message: .holderEnlargedScreenshotMessage,
			animated: true,
			actions: [
				.default(.ok)
			],
			presentingViewController: sut
		)
	}
}
