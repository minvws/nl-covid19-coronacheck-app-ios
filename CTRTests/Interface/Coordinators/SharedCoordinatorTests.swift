/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Shared
@testable import Models
@testable import Managers

class SharedCoordinatorTests: XCTestCase {

	private var sut: SharedCoordinator!
	private var navigationSpy: NavigationControllerSpy!
	private var window = UIWindow()
	private var onboardingFactorySpy: OnboardingFactorySpy!
	private var newFeaturesFactorySpy: NewFeaturesFactorySpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		
		navigationSpy = NavigationControllerSpy()
		onboardingFactorySpy = OnboardingFactorySpy()
		newFeaturesFactorySpy = NewFeaturesFactorySpy()
		newFeaturesFactorySpy.stubbedInformation = NewFeatureInformation(pages: [], version: 0)
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
			newFeaturesFactory: newFeaturesFactorySpy
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
			newFeaturesFactory: newFeaturesFactorySpy
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
			newFeaturesFactory: newFeaturesFactorySpy
		) {
			completed = true
		}
		// Then
		expect(completed).toEventually(beTrue())
		expect(self.sut.childCoordinators).toEventually(haveCount(0))
	}
	
	func test_needsNewFeatures() {
		
		// Given
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = [PagedAnnoucementItem(
			title: "",
			content: "",
			imageBackgroundColor: C.white(),
			tagline: "",
			step: 0
		)]
		
		var completed = false

		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			newFeaturesFactory: newFeaturesFactorySpy
		) {
			completed = true
		}

		// Then
		expect(completed) == false
		expect(self.sut.childCoordinators).toEventually(haveCount(1))
	}
	
	func test_consentGiven_updates_dependents() {
		
		// Arrange

		// Act
		sut.consentGiven()

		// Assert
		
		expect(self.environmentSpies.onboardingManagerSpy.invokedConsentGivenCount) == 1
		expect(self.environmentSpies.newFeaturesManagerSpy.invokedUserHasViewedNewFeatureIntroCount) == 1
	}
}
