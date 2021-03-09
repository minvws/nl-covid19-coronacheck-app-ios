/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class EnlargedQRViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: EnlargedQRViewController?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	var cryptoManagerSpy = CryptoManagerSpy()

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
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.sceneView.message, nil, "Message should match")
		XCTAssertFalse(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should not be shown")
		XCTAssertNil(strongSut.sceneView.largeQRimageView.image, "There should be no image")
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
		viewModel?.proofValidator = ProofValidator(maxValidity: 1)
		proofManagerSpy.birthDate = Date()
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() {

		// Given
		setupValidCredential()
		loadView()

		// When
		sut?.checkValidity()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.largeQRimageView.image, "There should be image")
		XCTAssertNotNil(strongSut.sceneView.title, "Title should not be nil")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CrypoAttributes(
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired"
		)
		viewModel?.proofValidator = ProofValidator(maxValidity: 1)
		loadView()

		// When
		sut?.checkValidity()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil
		loadView()

		// When
		sut?.checkValidity()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.dismissCalled, "Method should be called")
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
		XCTAssertTrue(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should not be shown")
		XCTAssertNotNil(strongSut.sceneView.largeQRimageView.image, "There should be image")
	}

	/// Test the security features
	func testSecurityFeaturesAnimation() {

		// Given
		setupValidCredential()
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.securityView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.largeQRimageView.isHidden, "Large QR should be shown")
		XCTAssertNotNil(strongSut.sceneView.largeQRimageView.image, "There should be image")
		XCTAssertEqual(strongSut.sceneView.securityView.currentAnimation, .cyclistRightToLeft, "Animation should match")
	}
}
