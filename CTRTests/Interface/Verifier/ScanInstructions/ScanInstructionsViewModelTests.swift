/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR
import SnapshotTesting

class ScanInstructionsViewModelTests: XCTestCase {

	var sut: ScanInstructionsViewModel!
	var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
	}

	func test_finishScanInstructions_whenRiskSettingIsShown_shouldInvokeUserDidCompletePages() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = false
		environmentSpies.riskLevelManagerSpy.stubbedState = .policy3G
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: []
		)

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserWishesToReadPolicyInformation) == false
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownSetter) == true
	}
	
	func test_finishScanInstructions_whenRiskSettingIsNotShown_shouldInvokeUserWishesToSelectRiskSetting_verificationPolicyEnabled() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = false
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.riskLevelManagerSpy.stubbedState = nil
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: []
		)

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserWishesToReadPolicyInformation) == false
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == true
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownSetter) == true
	}

	func test_finishScanInstructions_whenRiskSettingIsNotShown_shouldInvokeUserWishesToSelectRiskSetting_verificationPolicyDisabled() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = false
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.riskLevelManagerSpy.stubbedState = nil
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: []
		)

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserWishesToReadPolicyInformation) == false
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownSetter) == true
	}
	
	func test_finishScanInstructions_whenPolicyInformationIsNotShown_shouldInvokeUserWishesToReadPolicyInformation() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.riskLevelManagerSpy.stubbedState = nil
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: []
		)

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserWishesToReadPolicyInformation) == true
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownSetter) == true
	}

	func test_userTappedBackOnFirstPage_callsCoordinator() {

		// Arrange
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: [])

		// Act
		expect(self.coordinatorSpy.invokedUserDidCancelScanInstructions) == false
		sut.userTappedBackOnFirstPage()

		// Assert
		expect(self.coordinatorSpy.invokedUserDidCancelScanInstructions) == true
	}

	func test_creatingViewController() {
		// Arrange
		let pages = [
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages)

		// Act
		let viewController = sut.scanInstructionsViewController(forPage: pages[0])

		// Assert
		viewController.assertImage()
	}

	func test_skipButtonShownWhenUserFirstTimeExceptOnLastPage() {
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		
		let pages = [
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages)
		expect(self.sut.shouldShowSkipButton) == true

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.shouldShowSkipButton) == false
	}

	func test_skipButtonNotShownWhenNotFirstViewingOfInstructions() {
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true

		let pages = [
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages)
		expect(self.sut.shouldShowSkipButton) == false

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.shouldShowSkipButton) == false
	}

	func test_nextButtonTitleChangesOnLastPage() {
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.riskLevelManagerSpy.stubbedState = .policy3G
		let pages = [
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages)
		expect(self.sut.nextButtonTitle) == L.generalNext()

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.nextButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_nextButtonTitleChangesOnLastPage_whenScanLockIsEnabled() {
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.riskLevelManagerSpy.stubbedState = .policy3G
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: Date())
		let pages = [
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages)
		expect(self.sut.nextButtonTitle) == L.generalNext()

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.nextButtonTitle) == L.verifier_scan_instructions_back_to_start()
	}
}
