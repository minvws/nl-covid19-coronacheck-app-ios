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

	func testGetConsent() {

		// Given
		let expectedConsent = ForcedInformationConsent(
			title: .newTermsTitle,
			highlight: .newTermsHighlights,
			content: .newTermsDescription,
			consentMandatory: true
		)

		// When
		let actualConsent = sut.getConsent()

		// Then
		XCTAssertEqual(actualConsent, expectedConsent)
	}
}
