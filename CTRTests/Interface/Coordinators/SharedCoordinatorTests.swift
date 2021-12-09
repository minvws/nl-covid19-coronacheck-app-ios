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
	private var onboardingFactorySpy: OnboardingFactorySpy!
	private var forcedInformationFactorySpy: ForcedInformationFactorySpy!

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		onboardingFactorySpy = OnboardingFactorySpy()
		forcedInformationFactorySpy = ForcedInformationFactorySpy()
		forcedInformationFactorySpy.stubbedInformation = ForcedInformation(pages: [], consent: nil, version: 0)
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
		var completed = false

		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			forcedInformationFactory: forcedInformationFactorySpy
		) {
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
		var completed = false

		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			forcedInformationFactory: forcedInformationFactorySpy
		) {
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
		var completed = false

		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			forcedInformationFactory: forcedInformationFactorySpy
		) {
			completed = true
		}
		// Then
		expect(completed).toEventually(beTrue())
		expect(self.sut.childCoordinators).toEventually(haveCount(0))
	}
	
	func test_needsForcedInformation() {
		
		// Given
		let forcedInformationSpy = ForcedInformationManagerSpy()
		forcedInformationSpy.stubbedNeedsUpdating = true
		sut.forcedInformationManager = forcedInformationSpy
		var completed = false

		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			forcedInformationFactory: forcedInformationFactorySpy
		) {
			completed = true
		}

		// Then
		expect(completed) == false
		expect(self.sut.childCoordinators).to(haveCount(1))
	}
}
