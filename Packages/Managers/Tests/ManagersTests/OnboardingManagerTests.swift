/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import Managers

class OnboardingManagerTests: XCTestCase {

	// MARK: - Setup
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (OnboardingManager, SecureUserSettingsSpy) {
			
		let secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedOnboardingData = .empty
		
		let sut = OnboardingManager(secureUserSettings: secureUserSettingsSpy)
		
		trackForMemoryLeak(instance: secureUserSettingsSpy, file: file, line: line)
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, secureUserSettingsSpy)
	}
	
	// MARK: - Tests

	func testGetNeedsOnboarding() {

		// Given
		let (sut, _) = makeSUT()

		// When
		let value = sut.needsOnboarding

		// Then
		XCTAssertTrue(value, "needs onboarding should be true")
	}

	func testGetNeedsConsent() {

		// Given
		let (sut, _) = makeSUT()
		
		// When
		let value = sut.needsConsent

		// Then
		XCTAssertTrue(value, "needs consent should be true")
	}

	func testFinishOnboarding() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()
		
		// When
		sut.finishOnboarding()

		// Then
		XCTAssertFalse(secureUserSettingsSpy.invokedOnboardingData?.needsOnboarding ?? true, "needs onboarding should be false")
	}

	func testConsentGiven() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()

		// When
		sut.consentGiven()

		// Then
		XCTAssertFalse(secureUserSettingsSpy.invokedOnboardingData?.needsConsent ?? true, "needs consent should be false")
	}
}
