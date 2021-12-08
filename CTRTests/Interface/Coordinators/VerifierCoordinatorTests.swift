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
	private var scanLogManagerSpy: ScanLogManagingSpy!
	private var scanLockManagerSpy: ScanLockManagerSpy!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	private var window = UIWindow()

	override func setUp() {

		super.setUp()

		riskLevelManagerSpy = RiskLevelManagerSpy()
		Services.use(riskLevelManagerSpy)
		
		scanLogManagerSpy = ScanLogManagingSpy()
		Services.use(scanLogManagerSpy)

		scanLockManagerSpy = ScanLockManagerSpy()
		scanLockManagerSpy.stubbedState = .unlocked
		Services.use(scanLockManagerSpy)

		navigationSpy = NavigationControllerSpy()
		sut = VerifierCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	// MARK: - Tests
	
	func testFinishForcedInformation() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = false
		onboardingSpy.stubbedNeedsConsent = false
		sut.onboardingManager = onboardingSpy
		riskLevelManagerSpy.stubbedAppendObserverResult = UUID()
		scanLockManagerSpy.stubbedAppendObserverResult = UUID()

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
		expect(self.sut.childCoordinators).to(beEmpty())
	}

	func test_shouldCall_scanManagerRemoveOldEntries() {

		// Given
		let onboardingSpy = OnboardingManagerSpy()
		onboardingSpy.stubbedNeedsOnboarding = false
		onboardingSpy.stubbedNeedsConsent = false
		sut.onboardingManager = onboardingSpy
		riskLevelManagerSpy.stubbedAppendObserverResult = UUID()
		scanLockManagerSpy.stubbedAppendObserverResult = UUID()

		sut.start()
		
		// Then
		expect(self.scanLogManagerSpy.invokedDeleteExpiredScanLogEntries) == true
	}
}
