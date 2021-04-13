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

	var navigationSpy = NavigationControllerSpy()

	var window = UIWindow()

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		sut = HolderCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests

	func testOpenMenuItem() {

		// Given
		let menu = MenuViewController(
            viewModel: MenuViewModel(delegate: sut)
		)
		sut.sidePanel = CustomSidePanelController(sideController: UINavigationController(rootViewController: menu))

		let viewControllerSpy = ViewControllerSpy()
		sut.sidePanel?.selectedViewController = viewControllerSpy

		// When
		sut.openMenuItem(.privacy)

		// Then
		XCTAssertTrue(viewControllerSpy.presentCalled)
	}

	func testStartForcedInformation() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = false
		onboardingSpy.stubbedNeedsConsent = false
		sut.onboardingManager = onboardingSpy

		let forcedInformationSpy = ForcedInformationManagerSpy()
		forcedInformationSpy.stubbedNeedsUpdating = true
		forcedInformationSpy.stubbedGetConsentResult = ForcedInformationConsent(
			title: "test",
			highlight: "test",
			content: "test",
			consentMandatory: false
		)
		sut.forcedInformationManager = forcedInformationSpy

		// When
		sut.start()

		// Then
		XCTAssertFalse(sut.childCoordinators.isEmpty)
		XCTAssertTrue(sut.childCoordinators.first is ForcedInformationCoordinator)
	}

	func testFinishForcedInformation() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = false
		onboardingSpy.stubbedNeedsConsent = false
		sut.onboardingManager = onboardingSpy

		let forcedInformationSpy = ForcedInformationManagerSpy()
		forcedInformationSpy.stubbedNeedsUpdating = false
		sut.forcedInformationManager = forcedInformationSpy

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
