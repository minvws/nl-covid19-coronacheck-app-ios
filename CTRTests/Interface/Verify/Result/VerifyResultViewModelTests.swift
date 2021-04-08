/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifyResultViewModelTests: XCTestCase {

	/// Subject under test
	var sut: VerifierResultViewModel?

	/// The coordinator spy
	var verifyCoordinatorDelegateSpy = VerifyCoordinatorDelegateSpy()

	/// Date parser
	private lazy var parseDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()

	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifyCoordinatorDelegateSpy()

		sut = VerifierResultViewModel(
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
	}

	// MARK: - Tests

	/// Func test the demo qr
	func testDemo() {

		// Given
		sut?.cryptoResults = CryptoResult(
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

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .demo, "Type should be demo")
		XCTAssertEqual(sut?.title, .verifierResultDemoTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultAccessMessage, "Message should match")
	}

	/// Func test denied
	func testDenied() {

		// Given
		sut?.cryptoResults = CryptoResult(
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

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .denied, "Type should be denied")
		XCTAssertEqual(sut?.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultDeniedMessage, "Message should match")
	}

	/// Func test allowd
	func testAllow() {

		// Given
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40
		sut?.cryptoResults = CryptoResult(
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

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .verified, "Type should be verified")
		XCTAssertEqual(sut?.title, .verifierResultAccessTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultAccessMessage, "Message should match")
	}

	/// Func test allowed, qr time just within the grace period
	func testAllowWithInGracePeriod() {

		// Given
		let timeStamp175SecFromNow = Date().timeIntervalSince1970 + 175 // QR Time
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40 // Sample Time
		sut?.cryptoResults = CryptoResult(
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
					unixTimeStamp: Int64(timeStamp175SecFromNow)
				),
			errorMessage: nil
		)

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .verified, "Type should be verified")
		XCTAssertEqual(sut?.title, .verifierResultAccessTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultAccessMessage, "Message should match")
	}

	/// Func test denied, just outside the grace period
	func testDeniedOutsideInGracePeriod() {

		// Given
		let timeStamp185SecFromNow = Date().timeIntervalSince1970 + 185 // QR Time
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40 // Sample Time
		sut?.cryptoResults = CryptoResult(
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
					unixTimeStamp: Int64(timeStamp185SecFromNow)
				),
			errorMessage: nil
		)

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .denied, "Type should be denied")
		XCTAssertEqual(sut?.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultDeniedMessage, "Message should match")
	}

	/// Func test expired unit time stamp
	func testExpiredTimeStamp() {

		// Given
		let timeStamp310SecAgo = Date().timeIntervalSince1970 - 310 // TTL is 300
		sut?.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp310SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp310SecAgo)
				),
			errorMessage: nil
		)
		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .denied, "Type should be denied")
		XCTAssertEqual(sut?.title, .verifierResultDeniedTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultDeniedMessage, "Message should match")
	}

	/// Func test expired unit time stamp, but paperproof
	func testExpiredUnixTimeStampButPaperProof() {

		// Given
		let timeStamp310SecAgo = Date().timeIntervalSince1970 - 310 // TTL is 300
		sut?.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CrypoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp310SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "1"
					),
					unixTimeStamp: Int64(timeStamp310SecAgo)
				),
			errorMessage: nil
		)

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .verified, "Type should be verified")
		XCTAssertEqual(sut?.title, .verifierResultAccessTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierResultAccessMessage, "Message should match")
	}

    /// Test the dismiss method
    func testDismiss() {

        // Given

        // When
        sut?.dismiss()

        // Then
        XCTAssertTrue(verifyCoordinatorDelegateSpy.navigateToVerifierWelcomeCalled, "Method should be called")
    }

	/// Test the dismiss method
	func testScanAgain() {

		// Given

		// When
		sut?.scanAgain()

		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.navigateToScanCalled, "Method should be called")
	}

	/// Test the link tapped method
	func testLinkTappedDenied() {

		// Given
		sut?.allowAccess = .denied

		// When
		sut?.linkTapped()

		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.displayContentCalled, "Method should be called")
	}

	/// Test the link tapped method
	func testLinkTappedAllowed() {

		// Given
		sut?.allowAccess = .verified

		// When
		sut?.linkTapped()

		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.displayContentCalled, "Method should be called")
	}
}
