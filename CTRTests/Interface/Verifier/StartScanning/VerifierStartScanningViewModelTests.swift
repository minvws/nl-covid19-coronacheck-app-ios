/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Rswift

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

	// MARK: - Tests

	func test_defaultContent() {

		// Given
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)

		// When

		// Then
		expect(self.sut.primaryButtonTitle)
			.to(equal(L.verifierStartButtonTitle()), description: "Button title should match")
		expect(self.sut.title)
			.to(equal(L.verifierStartTitle()), description: "Title should match")
		expect(self.sut.header)
			.to(beNil(), description: "Header should be nil")
		expect(self.sut.message)
			.to(equal(L.verifierStartMessage()), description: "Message should match")
	}

	func test_primaryButtonTapped_noScanInstructionsShown() {

		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToInstructionsOrRiskSetting), description: "Result should match")
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownGetter) == true
	}

	func test_primaryButtonTapped_scanInstructionsShown_havePublicKeys() {

		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.cryptoManagerSpy.stubbedHasPublicKeysResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
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
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.cryptoManagerSpy.stubbedHasPublicKeysResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
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
	
	func test_primaryButtonTapped_policyInformationShown() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToInstructionsOrRiskSetting), description: "Result should match")
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownGetter) == true
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

	func test_clockDeviationWarning_isShown_whenHasClockDeviation() {

		// Arrange
		environmentSpies.clockDeviationManagerSpy.stubbedHasSignificantDeviation = true
		environmentSpies.clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = (true, ())

		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)

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
		environmentSpies.clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = (true, ())
		environmentSpies.clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverResult = ClockDeviationManager.ObserverToken()

		// Act
		sut = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)

		// Assert
		expect(self.environmentSpies.clockDeviationManagerSpy.invokedAppendDeviationChangeObserverCount) == 1
		expect(self.sut.shouldShowClockDeviationWarning) == true
	}
}
