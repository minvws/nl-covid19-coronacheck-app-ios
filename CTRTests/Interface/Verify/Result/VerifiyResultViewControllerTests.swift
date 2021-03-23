/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifyResultViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: VerifierResultViewController?
	
	/// The coordinator spy
	var verifyCoordinatorDelegateSpy = VerifyCoordinatorDelegateSpy()
	
	/// The view model
	var viewModel: VerifierResultViewModel?
	
	var window = UIWindow()
	
	// MARK: Test lifecycle
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifyCoordinatorDelegateSpy()
		
		viewModel = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			attributes: Attributes(
				cryptoAttributes: CrypoAttributes(
					birthDay: nil,
					birthMonth: nil,
					firstNameInitial: nil,
					lastNameInitial: nil,
					sampleTime: "test",
					testType: "test"
				),
				unixTimeStamp: 0
			),
			maxValidity: 48
		)
		sut = VerifierResultViewController(viewModel: viewModel!)
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
	
	/// Test all the demo content
	func testDemo() {
		
		// Given
		viewModel?.attributes = Attributes(
			cryptoAttributes: CrypoAttributes(
				birthDay: nil,
				birthMonth: nil,
				firstNameInitial: nil,
				lastNameInitial: nil,
				sampleTime: "test",
				testType: "demo"
			),
			unixTimeStamp: 0
		)
		loadView()
		
		// When
		viewModel?.checkAttributes()
		
		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.sceneView.title, .verifierResultDemoTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .verifierResultDemoMessage, "Message should match")
		XCTAssertEqual(strongSut.sceneView.imageView.image, .access, "Image should match")
		
	}
	
	/// Test all the denied content
	func testDenied() {
		
		// Given
		viewModel?.attributes = Attributes(
			cryptoAttributes: CrypoAttributes(
				birthDay: nil,
				birthMonth: nil,
				firstNameInitial: nil,
				lastNameInitial: nil,
				sampleTime: "test",
				testType: "pcr"
			),
			unixTimeStamp: 0
		)
		loadView()
		
		// When
		viewModel?.checkAttributes()
		
		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.sceneView.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .verifierResultDeniedMessage, "Message should match")
		XCTAssertEqual(strongSut.sceneView.imageView.image, .denied, "Image should match")
	}
	
	/// Test all the denied content
	func testDenied48hours() {
		
		// Given
		let timeStamp48HoursAgo = Date().timeIntervalSince1970 - (48 * 60 * 60) - 40
		viewModel?.attributes = Attributes(
			cryptoAttributes: CrypoAttributes(
				birthDay: nil,
				birthMonth: nil,
				firstNameInitial: nil,
				lastNameInitial: nil,
				sampleTime: "\(timeStamp48HoursAgo)",
				testType: "pcr"
			),
			unixTimeStamp: Int64(Date().timeIntervalSince1970)
		)
		loadView()
		
		// When
		viewModel?.checkAttributes()
		
		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.sceneView.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .verifierResultDeniedMessage, "Message should match")
		XCTAssertEqual(strongSut.sceneView.imageView.image, .denied, "Image should match")
	}
	
	/// Test all the verified content
	func testVerified() {
		
		// Given
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40
		viewModel?.attributes = Attributes(
			cryptoAttributes: CrypoAttributes(
				birthDay: nil,
				birthMonth: nil,
				firstNameInitial: nil,
				lastNameInitial: nil,
				sampleTime: "\(timeStamp40SecAgo)",
				testType: "pcr"
			),
			unixTimeStamp: Int64(timeStamp40SecAgo)
		)
		
		loadView()
		
		// When
		viewModel?.checkAttributes()
		
		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.sceneView.title, .verifierResultAccessTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .verifierResultAccessMessage, "Message should match")
		XCTAssertEqual(strongSut.sceneView.imageView.image, .access, "Image should match")
		
	}
	
	/// Test the dismiss method
	func testDismiss() {
		
		// Given
		
		// When
		sut?.closeButtonTapped()
		
		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}
	
	/// Test the link tapped method
	func testLinkTapped() {
		
		// Given
		
		// When
		sut?.linkTapped()
		
		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.displayContentCalled, "Method should be called")
	}
}
