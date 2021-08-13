/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class SharedCoordinatorTests: XCTestCase {

	private var sut: SharedCoordinator!
	private var navigationSpy: NavigationControllerSpy!
	private var window = UIWindow()

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		sut = SharedCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests
	
	func test_needsOnboarding() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = true
		onboardingSpy.stubbedNeedsConsent = true
		sut.onboardingManager = onboardingSpy
		let factory = OnboardingFactorySpy()
		var completed = false

		// When
		sut.handleOnboarding(factory: factory) {
			completed = true
		}

		// Then
		expect(completed) == false
		expect(self.sut.childCoordinators).to(haveCount(1))
	}

	func test_needsConsent() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = false
		onboardingSpy.stubbedNeedsConsent = true
		sut.onboardingManager = onboardingSpy
		let factory = OnboardingFactorySpy()
		var completed = false

		// When
		sut.handleOnboarding(factory: factory) {
			completed = true
		}

		// Then
		expect(completed) == false
		expect(self.sut.childCoordinators).to(haveCount(1))
	}

	func test_doesNotNeedOnboarding() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = false
		onboardingSpy.stubbedNeedsConsent = false
		sut.onboardingManager = onboardingSpy
		let factory = OnboardingFactorySpy()
		var completed = false

		// When
		sut.handleOnboarding(factory: factory) {
			completed = true
		}
		// Then
		expect(completed).toEventually(beTrue())
		expect(self.sut.childCoordinators).toEventually(haveCount(0))
	}
}
