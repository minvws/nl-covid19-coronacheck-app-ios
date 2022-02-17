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
		XCTAssertFalse(sut.childCoordinators.isEmpty)
		XCTAssertTrue(sut.childCoordinators.first is NewFeaturesCoordinator)
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
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = true
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
	}
	
	func test_handleDisclosurePolicyUpdates_shouldShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = true
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G"]
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_handleDisclosurePolicyUpdates_shouldNotShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = false
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		XCTAssertTrue(sut.childCoordinators.isEmpty)
	}
}
