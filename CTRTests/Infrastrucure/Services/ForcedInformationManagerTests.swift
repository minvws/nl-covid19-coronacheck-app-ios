/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ForcedInformationManagerTests: XCTestCase {

	// MARK: - Setup
	var sut: ForcedInformationManager!

	override func setUp() {

		sut = ForcedInformationManager()
		super.setUp()
	}

	override func tearDown() {

		sut.reset()
		super.tearDown()
	}

	// MARK: - Tests

	/// Test needs updating
	func testGetNeedsUpdating() {

		// Given
		sut.reset()

		// When

		// Then
		XCTAssertTrue(sut.needsUpdating)
	}

	func testConsentGiven() {

		// Given

		// When
		sut.consentGiven()

		// Then
		XCTAssertFalse(sut.needsUpdating)
	}

	func test_getUpdatePage() {

		// Given
		let expectedPage = ForcedInformationPage(
			image: .onboardingSafely,
			tagline: L.holderUpdatepageTagline(),
			title: L.holderUpdatepageTitle(),
			content: L.holderUpdatepageContent()
		)

		// When
		let actualPage = sut.getUpdatePage()

		// Then
		XCTAssertEqual(actualPage, expectedPage)
	}
}
