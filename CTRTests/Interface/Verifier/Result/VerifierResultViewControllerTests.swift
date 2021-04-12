/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifierResultViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: VerifierResultViewController!
	
	/// The coordinator spy
	var verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
	
	/// The view model
	var viewModel: VerifierResultViewModel!
	
	var window = UIWindow()
	
	// MARK: Test lifecycle
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		
		viewModel = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			cryptoResults: CryptoResult(
				attributes: Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "test",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
				errorMessage: nil
			),
			maxValidity: 48
		)
		sut = VerifierResultViewController(viewModel: viewModel)
		window = UIWindow()
	}

	func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	/// Test all the demo content
	func testDemo() throws {
		
		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "pcr",
						specimen: "1",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
			errorMessage: nil
		)
		loadView()
		
		// When
		viewModel.checkAttributes()
		
		// Then
		XCTAssertEqual(sut.sceneView.title, .verifierResultDemoTitle, "Title should match")
		XCTAssertEqual(sut.sceneView.message, .verifierResultAccessMessage, "Message should match")
		XCTAssertEqual(sut.sceneView.imageView.image, .access, "Image should match")
		
	}
	
	/// Test all the denied content
	func testDenied() throws {
		
		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
			errorMessage: nil
		)
		loadView()
		
		// When
		viewModel.checkAttributes()
		
		// Then
		XCTAssertEqual(sut.sceneView.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(sut.sceneView.message, .verifierResultDeniedMessage, "Message should match")
		XCTAssertEqual(sut.sceneView.imageView.image, .denied, "Image should match")
	}
	
	/// Test all the denied content
	func testDenied48hours() throws {
		
		// Given
		let timeStamp48HoursAgo = Date().timeIntervalSince1970 - (48 * 60 * 60) - 40
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp48HoursAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(Date().timeIntervalSince1970)
				),
			errorMessage: nil
		)
		loadView()
		
		// When
		viewModel.checkAttributes()
		
		// Then
		XCTAssertEqual(sut.sceneView.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(sut.sceneView.message, .verifierResultDeniedMessage, "Message should match")
		XCTAssertEqual(sut.sceneView.imageView.image, .denied, "Image should match")
	}
	
	/// Test all the verified content
	func testVerified() throws {
		
		// Given
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp40SecAgo)
				),
			errorMessage: nil
		)
		loadView()
		
		// When
		viewModel.checkAttributes()
		
		// Then
		XCTAssertEqual(sut.sceneView.title, .verifierResultAccessTitle, "Title should match")
		XCTAssertEqual(sut.sceneView.message, .verifierResultAccessMessage, "Message should match")
		XCTAssertEqual(sut.sceneView.imageView.image, .access, "Image should match")
	}
	
	/// Test the dismiss method
	func testDismiss() {
		
		// Given
		
		// When
		sut.closeButtonTapped()
		
		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.navigateToVerifierWelcomeCalled, "Method should be called")
	}

    func testPrimaryButtonTapped() {

        // Given
        loadView()

        // When
        sut.sceneView.primaryButtonTapped()

        // Then
        XCTAssertTrue(verifyCoordinatorDelegateSpy.navigateToScanCalled, "Method should be called")
    }
	
	/// Test the link tapped method
	func testLinkTapped() {
		
		// Given
		
		// When
		sut.linkTapped()
		
		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.displayContentCalled, "Method should be called")
	}

	/// Test the link tapped method
	func testDebugLinkTapped() throws {

		// Given

		// When
		sut.debugLinkTapped()

		// Then
		XCTAssertFalse(sut.sceneView.debugLabel.isHidden, "View should be visible")
	}
}
