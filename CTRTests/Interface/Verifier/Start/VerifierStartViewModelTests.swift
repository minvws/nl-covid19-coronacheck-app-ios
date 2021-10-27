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

class VerifierStartViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: VerifierStartViewModel!

	private var cryptoManagerSpy: CryptoManagerSpy!
	private var cryptoLibUtilitySpy: CryptoLibUtilitySpy!
	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var clockDeviationManagerSpy: ClockDeviationManagerSpy!
	private var userSettingsSpy: UserSettingsSpy!

	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		cryptoLibUtilitySpy = CryptoLibUtilitySpy(fileStorage: FileStorage(), flavor: AppFlavor.verifier)
		clockDeviationManagerSpy = ClockDeviationManagerSpy()
		userSettingsSpy = UserSettingsSpy()

		clockDeviationManagerSpy.stubbedHasSignificantDeviation = false
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = (false, ())
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverResult = ClockDeviationManager.ObserverToken()

		Services.use(cryptoLibUtilitySpy)
		Services.use(cryptoManagerSpy)
		Services.use(clockDeviationManagerSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	// MARK: - Tests

	func test_defaultContent() {

		// Given
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// When

		// Then
		expect(self.sut.primaryButtonTitle)
			.to(equal(L.verifierStartButtonTitle()), description: "Button title should match")
		expect(self.sut.title)
			.to(equal(L.verifierStartTitle()), description: "Title should match")
		expect(self.sut.header)
			.to(equal(L.verifierStartHeader()), description: "Header should match")
		expect(self.sut.message)
			.to(equal(L.verifierStartMessage()), description: "Message should match")
	}

	func test_primaryButtonTapped_noScanInstructionsShown() {

		// Given
		userSettingsSpy.stubbedScanInstructionShown = false
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScanInstructions), description: "Result should match")
		expect(self.userSettingsSpy.invokedScanInstructionShownGetter) == true
	}

	func test_primaryButtonTapped_scanInstructionsShown_havePublicKeys() {

		// Given
		userSettingsSpy.stubbedScanInstructionShown = true
		cryptoManagerSpy.stubbedHasPublicKeysResult = true
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScan), description: "Result should match")
	}

	func test_primaryButtonTapped_scanInstructionsShown_noPublicKeys() {

		// Given
		userSettingsSpy.stubbedScanInstructionShown = true
		cryptoManagerSpy.stubbedHasPublicKeysResult = false
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.cryptoLibUtilitySpy.invokedFetchIssuerPublicKeys) == true
		expect(self.sut.showError) == true
	}

	func test_showInstructionsButtonTapped() {

		// Given
		userSettingsSpy.stubbedScanInstructionShown = false
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// When
		sut.showInstructionsButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScanInstructions), description: "Result should match")
		expect(self.userSettingsSpy.invokedScanInstructionShownGetter) == false
	}

	func test_clockDeviationWarning_isShown_whenHasClockDeviation() {

		// Arrange
		clockDeviationManagerSpy.stubbedHasSignificantDeviation = true
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = (true, ())

		// Act
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// Assert
		expect(self.sut.shouldShowClockDeviationWarning) == true
	}

	func test_clockDeviationWarning_isNotShown_whenHasNoClockDeviation() {

		// Arrange
		clockDeviationManagerSpy.stubbedHasSignificantDeviation = false

		// Act
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// Assert
		expect(self.sut.shouldShowClockDeviationWarning) == false
	}

	func test_clockDeviationWarning_onUserTap_callsCoordinator() {

		// Arrange
		clockDeviationManagerSpy.stubbedHasSignificantDeviation = true

		// Act
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		expect(self.verifyCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviation) == false
		sut.userDidTapClockDeviationWarningReadMore()

		// Assert
		expect(self.verifyCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviation) == true
	}

	func test_clockDeviationWarning_onManagerUpdate_changesProperty() {

		// Arrange
		clockDeviationManagerSpy.stubbedHasSignificantDeviation = false
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = (true, ())
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverResult = ClockDeviationManager.ObserverToken()

		// Act
		sut = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			userSettings: userSettingsSpy
		)

		// Assert
		expect(self.clockDeviationManagerSpy.invokedAppendDeviationChangeObserverCount) == 1
		expect(self.sut.shouldShowClockDeviationWarning) == true
	}
}
