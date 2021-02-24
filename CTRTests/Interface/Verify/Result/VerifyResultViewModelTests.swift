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
	private lazy var parseDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		return dateFormatter
	}()

	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifyCoordinatorDelegateSpy()

		sut = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			attributes: Attributes(
				cryptoAttributes: CrypoAttributes(
					sampleTime: "test",
					testType: "test"
				),
				unixTimeStamp: 0
			)
		)
	}

	// MARK: - Tests

	func testDemo() {

		// Given
		sut?.attributes = Attributes(
			cryptoAttributes: CrypoAttributes(
				sampleTime: "test",
				testType: "demo"
			),
			unixTimeStamp: 0
		)

		// When
		sut?.checkAttributes()

		// Then
		XCTAssertEqual(sut?.allowAccess, .demo, "Type should be demo")
		XCTAssertEqual(sut?.message, .verifierResultDemoMessage, "Message should match")
	}

	/// Test the dismiss method
	func testDismiss() {

		// Given

		// When
		sut?.dismiss()

		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}

	/// Test the link tapped method
	func testLinkTapped() {

		// Given

		// When
		sut?.linkTapped()

		// Then
		XCTAssertTrue(verifyCoordinatorDelegateSpy.presentInformationPageCalled, "Method should be called")
	}
}
