/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OnboardingCoordinatorTests: XCTestCase {

	var sut: OnboardingCoordinator?
	var onboardingDelegateSpy = OnboardingDelegateSpy()
	var navigationSpy = NavigationControllerSpy()

	override func setUp() {

		super.setUp()

		onboardingDelegateSpy = OnboardingDelegateSpy()
		navigationSpy = NavigationControllerSpy()
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy
		)
	}

	// MARK: Test Doubles

	class OnboardingDelegateSpy: OnboardingDelegate {

		var finishOnboardingCalled = false

		func finishOnboarding() {
			finishOnboardingCalled = true
		}
	}

	// MARK: - Tests

	func testInitializer() {

		// Given

		// When

		// Then
		XCTAssertEqual(sut?.onboardingPages.count, 5, "There should be 5 pages")
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 0, "There should be no pages pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should not be called")
	}

	func testStart() {

		// Given

		// When
		sut?.start()

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be no pages pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should not be called")
	}

	func testNextButtonClickedFirstPage() {

		// Given

		// When
		sut?.nextButtonClicked(step: .safelyOnTheRoad)

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be one page pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should not be called")
	}

	func testNextButtonClickedSecondPage() {

		// Given

		// When
		sut?.nextButtonClicked(step: .yourQR)

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be one page pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should not be called")
	}

	func testNextButtonClickedThirdPage() {

		// Given

		// When
		sut?.nextButtonClicked(step: .validity)

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be one page pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should not be called")
	}

	func testNextButtonClickedForthPage() {

		// Given

		// When
		sut?.nextButtonClicked(step: .safeSystem)

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be one page pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should not be called")
	}

	func testNextButtonClickedFifthPage() {

		// Given

		// When
		sut?.nextButtonClicked(step: .privacy)

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be a page pushed")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should be called")
	}

	func testNextButtonClickedTerms() {

		// Given

		// When
		sut?.termsAgreed()

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 0, "There should be no page pushed")
		XCTAssertTrue(onboardingDelegateSpy.finishOnboardingCalled, "Method should be called")
	}

}
