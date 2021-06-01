/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifierCoordinatorTests: XCTestCase {

	var sut: VerifierCoordinator!

	var navigationSpy: NavigationControllerSpy!

	var window = UIWindow()

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		sut = VerifierCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests
	
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
