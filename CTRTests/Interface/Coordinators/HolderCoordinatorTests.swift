/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

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

	func testStartForcedInformation() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.forcedInformationManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.forcedInformationManagerSpy.stubbedGetUpdatePageResult = ForcedInformationPage(
			image: nil,
			tagline: "test",
			title: "test",
			content: "test"
		)

		// When
		sut.start()

		// Then
		XCTAssertFalse(sut.childCoordinators.isEmpty)
		XCTAssertTrue(sut.childCoordinators.first is ForcedInformationCoordinator)
	}

	func testFinishForcedInformation() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.forcedInformationManagerSpy.stubbedNeedsUpdating = false

		environmentSpies.remoteConfigManagerSpy.stubbedAppendUpdateObserverResult = UUID()
		environmentSpies.remoteConfigManagerSpy.stubbedAppendReloadObserverResult = UUID()
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default

		sut.childCoordinators = [
			ForcedInformationCoordinator(
				navigationController: navigationSpy,
				forcedInformationManager: ForcedInformationManagerSpy(),
				delegate: sut
			)
		]

		// When
		sut.finishForcedInformation()

		// Then
		XCTAssertTrue(sut.childCoordinators.isEmpty)
	}
}
