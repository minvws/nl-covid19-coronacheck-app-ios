/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import Managers

class OnboardingManagerTests: XCTestCase {

	// MARK: - Setup
	var sut: OnboardingManager!
	var secureUserSettingsSpy: SecureUserSettingsSpy!
	
	override func setUp() {

		secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedOnboardingData = .empty
		
		sut = OnboardingManager(secureUserSettings: secureUserSettingsSpy)
		super.setUp()
	}

	// MARK: - Tests

	func testGetNeedsOnboarding() {

		// Given

		// When
		let value = sut.needsOnboarding

		// Then
		XCTAssertTrue(value, "needs onboarding should be true")
	}

	func testGetNeedsConsent() {

		// Given

		// When
		let value = sut.needsConsent

		// Then
		XCTAssertTrue(value, "needs consent should be true")
	}

	func testFinishOnboarding() {

		// Given

		// When
		sut.finishOnboarding()

		// Then
		XCTAssertFalse(secureUserSettingsSpy.invokedOnboardingData?.needsOnboarding ?? true, "needs onboarding should be false")
	}

	func testConsentGiven() {

		// Given

		// When
		sut.consentGiven()

		// Then
		XCTAssertFalse(secureUserSettingsSpy.invokedOnboardingData?.needsConsent ?? true, "needs consent should be false")
	}
}
