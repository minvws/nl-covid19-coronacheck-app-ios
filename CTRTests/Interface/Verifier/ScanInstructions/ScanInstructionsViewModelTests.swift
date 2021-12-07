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
	var scanLogManagingSpy: ScanLogManagingSpy!
	var configuration: RemoteConfiguration!

	override func setUp() {
		super.setUp()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
		riskLevelManagingSpy = RiskLevelManagerSpy()
		scanLogManagingSpy = ScanLogManagingSpy()
		configuration = .default
	}

	func test_finishScanInstructions_callsCoordinator() {

		// Arrange
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy,
			pages: [],
			userSettings: userSettingsSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLogManager: scanLogManagingSpy,
			configuration: configuration
		)
		userSettingsSpy.stubbedScanInstructionShown = true

		// Act
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
	}

	func test_userTappedBackOnFirstPage_callsCoordinator() {

		// Arrange
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy,
										pages: [],
										userSettings: userSettingsSpy,
										riskLevelManager: riskLevelManagingSpy,
										scanLogManager: scanLogManagingSpy,
										configuration: configuration)

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
										scanLogManager: scanLogManagingSpy,
										configuration: configuration)

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
										scanLogManager: scanLogManagingSpy,
										configuration: configuration)
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
										scanLogManager: scanLogManagingSpy,
										configuration: configuration)
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
										scanLogManager: scanLogManagingSpy,
										configuration: configuration)
		expect(self.sut.nextButtonTitle) == L.generalNext()

		sut.userDidChangeCurrentPage(toPageIndex: 1)
		expect(self.sut.nextButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
}
