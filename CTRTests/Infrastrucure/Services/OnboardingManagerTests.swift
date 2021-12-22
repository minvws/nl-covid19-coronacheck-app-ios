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
	var sut = OnboardingManager(secureUserSettings: SecureUserSettings())
	var secureUserSettingsSpy: SecureUserSettingsSpy!
	
	override func setUp() {

		secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedOnboardingData = .empty
		
		sut = OnboardingManager(secureUserSettings: secureUserSettingsSpy)
		super.setUp()
	}

	override func tearDown() {

		Services.secureUserSettings.reset()
		super.tearDown()
	}

	// MARK: - Tests

	func testGetNeedsOnboarding() {

		// Given
		Services.secureUserSettings.reset()

		// When
		let value = sut.needsOnboarding

		// Then
		XCTAssertTrue(value, "needs onboarding should be true")
	}

	func testGetNeedsConsent() {

		// Given
		Services.secureUserSettings.reset()

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
