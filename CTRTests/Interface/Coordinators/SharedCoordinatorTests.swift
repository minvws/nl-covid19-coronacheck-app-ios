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
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		
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
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		
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
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		
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
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
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
		environmentSpies.forcedInformationManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.forcedInformationManagerSpy.stubbedGetUpdatePageResult = ForcedInformationPage(image: nil, tagline: "", title: "", content: "")
		
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
		expect(self.sut.childCoordinators).toEventually(haveCount(1))
	}
}
