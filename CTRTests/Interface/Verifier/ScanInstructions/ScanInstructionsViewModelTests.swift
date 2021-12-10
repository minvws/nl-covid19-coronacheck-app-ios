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

class ScanInstructionsViewModelTests: XCTestCase {

	var sut: ScanInstructionsViewModel!
	var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	var userSettingsSpy: UserSettingsSpy!
	var riskLevelManagingSpy: RiskLevelManagerSpy!
	var scanLockManagingSpy: ScanLockManagerSpy!

	override func setUp() {
		super.setUp()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
		riskLevelManagingSpy = RiskLevelManagerSpy()
		scanLockManagingSpy = ScanLockManagerSpy()
		
		scanLockManagingSpy.stubbedAppendObserverResult = UUID()
		scanLockManagingSpy.stubbedState = .unlocked
	}

	func test_finishScanInstructions_whenRiskSettingIsShown_shouldInvokeUserDidCompletePages() {

		// Arrange
		riskLevelManagingSpy.stubbedState = .low
		userSettingsSpy.stubbedScanInstructionShown = true
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: [],
			userSettings: userSettingsSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLockManager: scanLockManagingSpy
		)

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
		expect(self.userSettingsSpy.invokedScanInstructionShownSetter) == true
	}
	
	func test_finishScanInstructions_whenRiskSettingIsNotShown_shouldInvokeUserWishesToSelectRiskSetting() {

		// Arrange
		userSettingsSpy.stubbedScanInstructionShown = true
		riskLevelManagingSpy.stubbedState = nil
		scanLockManagingSpy.stubbedState = .unlocked
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: [],
			userSettings: userSettingsSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLockManager: scanLockManagingSpy
		)

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == true
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
		expect(self.userSettingsSpy.invokedScanInstructionShownSetter) == true
	}

	func test_userTappedBackOnFirstPage_callsCoordinator() {

		// Arrange
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: [],
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLockManager: scanLockManagingSpy)

		// Act
		expect(self.coordinatorSpy.invokedUserDidCancelScanInstructions) == false
		sut.userTappedBackOnFirstPage()

		// Assert
		expect(self.coordinatorSpy.invokedUserDidCancelScanInstructions) == true
	}

	func test_creatingViewController() {
		// Arrange
		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages,
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLockManager: scanLockManagingSpy)

		// Act
		let viewController = sut.scanInstructionsViewController(forPage: pages[0])

		// Assert
		viewController.assertImage()
	}

	func test_skipButtonShownWhenUserFirstTimeExceptOnLastPage() {
		userSettingsSpy.stubbedScanInstructionShown = false
		
		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages,
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLockManager: scanLockManagingSpy)
		expect(self.sut.shouldShowSkipButton) == true

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.shouldShowSkipButton) == false
	}

	func test_skipButtonNotShownWhenNotFirstViewingOfInstructions() {
		userSettingsSpy.stubbedScanInstructionShown = true

		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages,
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLockManager: scanLockManagingSpy)
		expect(self.sut.shouldShowSkipButton) == false

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.shouldShowSkipButton) == false
	}

	func test_nextButtonTitleChangesOnLastPage() {
		userSettingsSpy.stubbedScanInstructionShown = true
		riskLevelManagingSpy.stubbedState = .low
		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages,
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLockManager: scanLockManagingSpy)
		expect(self.sut.nextButtonTitle) == L.generalNext()

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.nextButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_nextButtonTitleChangesOnLastPage_whenScanLockIsEnabled() {
		userSettingsSpy.stubbedScanInstructionShown = true
		riskLevelManagingSpy.stubbedState = .low
		scanLockManagingSpy.stubbedState = .locked(until: Date())
		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: pages,
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLockManager: scanLockManagingSpy)
		expect(self.sut.nextButtonTitle) == L.generalNext()

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.nextButtonTitle) == L.verifier_scan_instructions_back_to_start()
	}
}
