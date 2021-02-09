/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OnboardingManagerTests: XCTestCase {

	// MARK: - Setup
	var sut = OnboardingManager()

	override func setUp() {

		sut = OnboardingManager()
		super.setUp()
	}

	override func tearDown() {

		sut.reset()
		super.tearDown()
	}

	// MARK: - Tests

	func testGetNeedsOnboarding() {

		// Given
		sut.reset()

		// When
		let value = sut.needsOnboarding

		// Then
		XCTAssertTrue(value, "needs onboarding should be true")
	}

	func testGetNeedsConsent() {

		// Given
		sut.reset()

		// When
		let value = sut.needsConsent

		// Then
		XCTAssertTrue(value, "needs consent should be true")
	}

	func testFinishOnboarding() {

		// Given

		// When
		sut.finishOnboarding()

		let value = sut.needsOnboarding

		// Then
		XCTAssertFalse(value, "needs onboarding should be false")
	}

	func testConsentGiven() {

		// Given

		// When
		sut.consentGiven()

		let value = sut.needsConsent

		// Then
		XCTAssertFalse(value, "needs consent should be false")
	}
}
