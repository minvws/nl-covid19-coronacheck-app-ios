/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class HolderCoordinatorTests: XCTestCase {

	var sut: HolderCoordinator!

	var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		navigationSpy = NavigationControllerSpy()
		sut = HolderCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests

	func testStartNewFeatures() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.newFeaturesManagerSpy.stubbedGetUpdatePageResult = NewFeatureItem(
			image: nil,
			tagline: "test",
			title: "test",
			content: "test"
		)

		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).toNot(beEmpty())
		expect(self.sut.childCoordinators.first is NewFeaturesCoordinator) == true
	}

	func testFinishNewFeatures() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false

		environmentSpies.remoteConfigManagerSpy.stubbedAppendUpdateObserverResult = UUID()
		environmentSpies.remoteConfigManagerSpy.stubbedAppendReloadObserverResult = UUID()
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default

		sut.childCoordinators = [
			NewFeaturesCoordinator(
				navigationController: navigationSpy,
				newFeaturesManager: NewFeaturesManagerSpy(),
				delegate: sut
			)
		]

		// When
		sut.finishNewFeatures()

		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_handleDisclosurePolicyUpdates_needsOnboarding() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		environmentSpies.userSettingsSpy.shouldShowDisclosurePolicyUpdate = true
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
	}
	
	func test_handleDisclosurePolicyUpdates_shouldShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.userSettingsSpy.stubbedShouldShowDisclosurePolicyUpdate = true
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_handleDisclosurePolicyUpdates_shouldNotShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.userSettingsSpy.stubbedShouldShowDisclosurePolicyUpdate = false
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
	}
}
