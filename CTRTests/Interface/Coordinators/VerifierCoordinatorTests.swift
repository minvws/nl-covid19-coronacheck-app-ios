/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class VerifierCoordinatorTests: XCTestCase {

	private var sut: VerifierCoordinator!

	private var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	private var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()

		navigationSpy = NavigationControllerSpy()
		sut = VerifierCoordinator(
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
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false

		sut.childCoordinators = [
			NewFeaturesCoordinator(
				navigationController: navigationSpy,
				newFeaturesManager: environmentSpies.newFeaturesManagerSpy,
				delegate: sut
			)
		]

		// When
		sut.finishNewFeatures()

		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}

	func test_shouldNoLongerCall_scanManagerRemoveOldEntries() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		
		sut.start()
		
		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedDeleteExpiredScanLogEntries) == false
	}
}
