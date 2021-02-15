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
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
	}

	// MARK: Test Doubles

	class OnboardingDelegateSpy: OnboardingDelegate {

		var consentGivenCalled = false
		var finishOnboardingCalled = false

		func consentGiven() {

			consentGivenCalled = true
		}

		func finishOnboarding() {

			finishOnboardingCalled = true
		}
	}

	// MARK: - Test Doubles

	class ViewControllerSpy: UIViewController {

		var presentCalled = false
		var dismissCalled = false

		override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {

			presentCalled = true
			super.present(viewControllerToPresent, animated: flag, completion: completion)
		}

		override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
			dismissCalled = true
			super.dismiss(animated: flag, completion: completion)
		}
	}

	// MARK: - Tests

	func testInitializer() {

		// Given

		// When

		// Then
		XCTAssertEqual(sut?.onboardingPages.count, 5, "There should be 5 pages")
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 0, "There should be no pages pushed")
		XCTAssertFalse(onboardingDelegateSpy.consentGivenCalled, "Method should NOT be called")
	}

	/// Test the start call
	func testStart() {

		// Given

		// When
		sut?.start()

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be no pages pushed")
		XCTAssertFalse(onboardingDelegateSpy.consentGivenCalled, "Method should NOT be called")
	}

	/// Test the show privacy page call
	func testShowPrivacyPage() {

		// Given
		let viewControllerSpy = ViewControllerSpy()

		// When
		sut?.showPrivacyPage(viewControllerSpy)

		// Then
		XCTAssertTrue(viewControllerSpy.presentCalled, "The method should be called")
		XCTAssertFalse(onboardingDelegateSpy.consentGivenCalled, "Method should NOT be called")
	}

	/// Test the dimiss call
	func testDismiss() {

		// Given
		let viewControllerSpy = ViewControllerSpy()
		sut?.showPrivacyPage(viewControllerSpy)

		// When
		sut?.dismiss()

		// Then
		XCTAssertTrue(viewControllerSpy.dismissCalled, "The method should be called")
		XCTAssertFalse(onboardingDelegateSpy.consentGivenCalled, "Method should NOT be called")
	}

	/// Test the finish onboarding call
	func testFinishOnboarding() {

		// Given

		// When
		sut?.finishOnboarding()

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "There should be one page pushed")
		XCTAssertFalse(onboardingDelegateSpy.consentGivenCalled, "Method should NOT be called")
		XCTAssertTrue(onboardingDelegateSpy.finishOnboardingCalled, "Method should be called")
	}

	/// Test the consent given call
	func testConsentGiven() {

		// Given

		// When
		sut?.consentGiven()

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 0, "There should be no pages pushed")
		XCTAssertTrue(onboardingDelegateSpy.consentGivenCalled, "Method should be called")
		XCTAssertFalse(onboardingDelegateSpy.finishOnboardingCalled, "Method should NOT be called")
	}
}
