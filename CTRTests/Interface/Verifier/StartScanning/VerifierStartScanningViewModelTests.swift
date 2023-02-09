/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Shared
@testable import CTR
import Nimble
import TestingShared
import Persistence

class VerifierStartScanningViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: VerifierStartScanningViewModel!
	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
	}
	
	// MARK: - Initial State
	
	func test_initialState_unlocked_nilPolicy() {
		// Arrange
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		assertSutUnlockedWithNilPolicy()
	}
	
	func test_initialState_unlocked_3GPolicy() {
		// Arrange
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		assertSutUnlockedWith3GPolicy()
	}
	
	func test_initialState_unlocked_1GPolicy() {
		// Arrange
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		assertSutUnlockedWith1GPolicy()
	}
	
	func test_initialState_locked_nilPolicy() {
		// Arrange
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: now.addingTimeInterval(30))
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		assertSutLockedWithNilPolicy()
	}
	
	func test_initialState_locked_3GPolicy() {
		// Arrange
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: now.addingTimeInterval(30))
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		assertSutLockedWith3GPolicy()
	}
	
	func test_initialState_locked_1GPolicy() {
		// Arrange
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: now.addingTimeInterval(30))
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		assertSutLockedWith1GPolicy()
	}
	
	// MARK: - Primary Button behaviour -
	
	func test_primaryButtonTapped_scanInstructionsShown_havePublicKeys() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedHasPublicKeysResult = true
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScan), description: "Result should match")
	}
	
	func test_primaryButtonTapped_scanInstructionsShown_noPublicKeys() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedHasPublicKeysResult = false
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.sut.showError) == true
	}
	
	func test_primaryButtonTapped_locked_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: Date().addingTimeInterval(10 * minute))
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == false
	}
	
	func test_primaryButtonTapped_locked_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: Date().addingTimeInterval(10 * minute))
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == false
	}
	
	func test_showInstructionsButtonTapped() {
		
		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// When
		sut.showInstructionsButtonTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScanInstructions), description: "Result should match")
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownGetter) == false
	}
	
	// MARK: - Clock Deviation -
	
	func test_clockDeviationWarning_isShown_whenHasClockDeviation() {
		
		// Arrange
		environmentSpies.clockDeviationManagerSpy.stubbedHasSignificantDeviation = true
		
		var sendUpdate: ((Bool) -> Void)?
		(environmentSpies.clockDeviationManagerSpy.stubbedObservatory, sendUpdate) = Observatory<Bool>.create()

		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		sendUpdate?(true)
		
		// Assert
		expect(self.sut.shouldShowClockDeviationWarning) == true
	}
	
	func test_clockDeviationWarning_isNotShown_whenHasNoClockDeviation() {
		
		// Arrange
		environmentSpies.clockDeviationManagerSpy.stubbedHasSignificantDeviation = false
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert
		expect(self.sut.shouldShowClockDeviationWarning) == false
	}
	
	func test_clockDeviationWarning_onUserTap_callsCoordinator() {
		
		// Arrange
		environmentSpies.clockDeviationManagerSpy.stubbedHasSignificantDeviation = true
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		expect(self.verifyCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviation) == false
		sut.userDidTapClockDeviationWarningReadMore()
		
		// Assert
		expect(self.verifyCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviation) == true
	}
	
	func test_clockDeviationWarning_onManagerUpdate_changesProperty() {
		
		// Arrange
		environmentSpies.clockDeviationManagerSpy.stubbedHasSignificantDeviation = false

		var sendUpdate: ((Bool) -> Void)?
		(environmentSpies.clockDeviationManagerSpy.stubbedObservatory, sendUpdate) = Observatory<Bool>.create()
		
		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		sendUpdate?(true)
		
		// Assert
		expect(self.sut.shouldShowClockDeviationWarning) == true
	}
	
	// MARK: - ScanLockManager and VerificationPolicyManager observations -
	
	func test_manipulatingObservations_mutatesStateCorrectly() {
		
		// Create observatories so that we can control to manipulate `sut`:
		let sendScanLockUpdate: ((ScanLockManager.State) -> Void)!
		let sendVerificationPolicyUpdate: ((VerificationPolicy?) -> Void)!
		
		(environmentSpies.scanLockManagerSpy.stubbedObservatory, sendScanLockUpdate) = Observatory.create()
		(environmentSpies.verificationPolicyManagerSpy.stubbedObservatory, sendVerificationPolicyUpdate) = Observatory.create()
		
		// Starts unlocked and 1G verificationPolicy (due to `environmentSpies` defaults)
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// Assert starting state
		assertSutUnlockedWith1GPolicy()
		
		// Lock!
		sendScanLockUpdate(.locked(until: now.addingTimeInterval(30)))
		assertSutLockedWith1GPolicy()
		
		// Policy changed to 3G
		sendVerificationPolicyUpdate(.policy3G)
		assertSutLockedWith3GPolicy()
		
		// Unlock
		sendScanLockUpdate(.unlocked)
		assertSutUnlockedWith3GPolicy()
		
		// Set policy to nil
		sendVerificationPolicyUpdate(nil)
		assertSutUnlockedWithNilPolicy()
	}
	
	// MARK: - Timer
	
	func test_manipulatingTimer_mutatesStateCorrectly() {
		
		// Create observatories so that we can control to manipulate `sut`:
		let sendScanLockUpdate: ((ScanLockManager.State) -> Void)!
		(environmentSpies.scanLockManagerSpy.stubbedObservatory, sendScanLockUpdate) = Observatory.create()
		
		var timerSpy: TimerSpy?
		var timerAction: (() -> Void)?
		
		// Starts unlocked and 1G verificationPolicy (due to `environmentSpies` defaults)
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy, vendTimer: { timeInterval, repeats, action in
			guard timerSpy == nil else {
				fail("Expected to vend one timer")
				return TimerSpy()
			}
			
			expect(timeInterval) == 1
			expect(repeats) == true
			timerAction = action
			
			timerSpy = TimerSpy()
			return timerSpy!
		})
		
		expect(timerSpy?.invokedFire) == true
		
		// Assert starting state
		assertSutUnlockedWith1GPolicy()

		// Lock!
		sendScanLockUpdate(.locked(until: now.addingTimeInterval(30)))
		
		// tick the timer
		timerAction!()
		expect(self.sut.header).toEventually(equal(L.verifier_home_countdown_title("00:29")))
		
		// tick again
		timerAction!()
		expect(self.sut.header).toEventually(equal(L.verifier_home_countdown_title("00:28")))
		
		// Tick timer down to zero
		for _ in (0 ..< 28) { timerAction!() }
		
		expect(self.sut.header).toEventually(equal(L.verifier_home_countdown_title("00:00")))
	}
	
	func test_userWishesToOpenTheMenu() {
		
		// Given
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		
		// When
		sut.userTappedMenuButton()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedUserWishesToOpenTheMenu) == true
	}
	
	// MARK: - Helpers
	
	private func assertSutUnlockedWithNilPolicy() {
		expect(self.sut.title) == L.verifierStartTitle()
		expect(self.sut.header).toEventually(beNil())
		expect(self.sut.headerMode).toEventually(equal(I.scanner.scanStart3GPolicy().map { .image($0) }))
		expect(self.sut.message).toEventually(equal(L.verifierStartMessage()))
		expect(self.sut.primaryButtonTitle).toEventually(equal(L.verifierStartButtonTitle()))
		expect(self.sut.showsPrimaryButton).toEventually(equal(true))
		expect(self.sut.showInstructionsTitle).toEventually(equal(L.verifierStartButtonShowinstructions()))
		expect(self.sut.showsInstructionsButton).toEventually(equal(true))
		expect(self.sut.showError).toEventually(equal(false))
		expect(self.sut.shouldShowClockDeviationWarning).toEventually(equal(false))
		expect(self.sut.riskIndicator).toEventually(beNil())
	}
	
	private func assertSutUnlockedWith1GPolicy() {
		expect(self.sut.title).toEventually(equal(L.verifierStartTitle()))
		expect(self.sut.header).toEventually(beNil())
		expect(self.sut.headerMode).toEventually(equal(I.scanner.scanStart1GPolicy().map { .image($0) }))
		expect(self.sut.message).toEventually(equal(L.scan_qr_description_1G()))
		expect(self.sut.primaryButtonTitle).toEventually(equal(L.verifierStartButtonTitle()))
		expect(self.sut.showsPrimaryButton).toEventually(equal(true))
		expect(self.sut.showInstructionsTitle).toEventually(equal(L.verifierStartButtonShowinstructions()))
		expect(self.sut.showsInstructionsButton).toEventually(equal(true))
		expect(self.sut.showError).toEventually(equal(false))
		expect(self.sut.shouldShowClockDeviationWarning).toEventually(equal(false))
		expect(self.sut.riskIndicator).toEventually(equal((C.primaryBlue()!, L.verifier_start_scan_qr_policy_indication(VerificationPolicy.policy1G.localization))))
	}
	
	private func assertSutUnlockedWith3GPolicy() {
		expect(self.sut.title).toEventually(equal(L.verifierStartTitle()))
		expect(self.sut.header).toEventually(beNil())
		expect(self.sut.headerMode).toEventually(equal(I.scanner.scanStart3GPolicy().map { .image($0) }))
		expect(self.sut.message).toEventually(equal(L.verifierStartMessage()))
		expect(self.sut.primaryButtonTitle).toEventually(equal(L.verifierStartButtonTitle()))
		expect(self.sut.showsPrimaryButton).toEventually(equal(true))
		expect(self.sut.showInstructionsTitle).toEventually(equal(L.verifierStartButtonShowinstructions()))
		expect(self.sut.showsInstructionsButton).toEventually(equal(true))
		expect(self.sut.showError).toEventually(equal(false))
		expect(self.sut.shouldShowClockDeviationWarning).toEventually(equal(false))
		expect(self.sut.riskIndicator).toEventually(equal((C.secondaryGreen()!, L.verifier_start_scan_qr_policy_indication(VerificationPolicy.policy3G.localization))))
	}
	
	private func assertSutLockedWithNilPolicy() {
		expect(self.sut.title) == L.verifierStartTitle()
		expect(self.sut.header).toEventually(equal(L.verifier_home_countdown_title("00:29")), timeout: .seconds(3))
		expect(self.sut.headerMode).toEventually(beNil())
		expect(self.sut.message).toEventually(equal(L.verifier_home_countdown_subtitle(1)))
		expect(self.sut.primaryButtonTitle).toEventually(equal(L.verifierStartButtonTitle()))
		expect(self.sut.showsPrimaryButton).toEventually(equal(false))
		expect(self.sut.showInstructionsTitle).toEventually(beNil())
		expect(self.sut.showsInstructionsButton).toEventually(equal(false))
		expect(self.sut.showError).toEventually(equal(false))
		expect(self.sut.shouldShowClockDeviationWarning).toEventually(equal(false))
		expect(self.sut.riskIndicator).toEventually(beNil())
	}
	
	private func assertSutLockedWith3GPolicy() {
		expect(self.sut.title) == L.verifierStartTitle()
		expect(self.sut.header).toEventually(equal(L.verifier_home_countdown_title("00:29")), timeout: .seconds(3))
		expect(self.sut.headerMode).toEventually(equal(.animation("switch_to_green_animation")))
		expect(self.sut.message).toEventually(equal(L.verifier_home_countdown_subtitle(1)))
		expect(self.sut.primaryButtonTitle).toEventually(equal(L.verifierStartButtonTitle()))
		expect(self.sut.showsPrimaryButton).toEventually(equal(false))
		expect(self.sut.showInstructionsTitle).toEventually(beNil())
		expect(self.sut.showsInstructionsButton).toEventually(equal(false))
		expect(self.sut.showError).toEventually(equal(false))
		expect(self.sut.shouldShowClockDeviationWarning).toEventually(equal(false))
		expect(self.sut.riskIndicator).toEventually(equal((C.secondaryGreen()!, L.verifier_start_scan_qr_policy_indication(VerificationPolicy.policy3G.localization))))
	}
	
	private func assertSutLockedWith1GPolicy() {
		expect(self.sut.title) == L.verifierStartTitle()
		expect(self.sut.header).toEventually(equal(L.verifier_home_countdown_title("00:29")), timeout: .seconds(3))
		expect(self.sut.headerMode).toEventually(equal(.animation("switch_to_blue_animation")))
		expect(self.sut.message).toEventually(equal(L.verifier_home_countdown_subtitle(1)))
		expect(self.sut.primaryButtonTitle).toEventually(equal(L.verifierStartButtonTitle()))
		expect(self.sut.showsPrimaryButton).toEventually(equal(false))
		expect(self.sut.showInstructionsTitle).toEventually(beNil())
		expect(self.sut.showsInstructionsButton).toEventually(equal(false))
		expect(self.sut.showError).toEventually(equal(false))
		expect(self.sut.shouldShowClockDeviationWarning).toEventually(equal(false))
		expect(self.sut.riskIndicator).toEventually(equal((C.primaryBlue()!, L.verifier_start_scan_qr_policy_indication(VerificationPolicy.policy1G.localization))))
	}
}
