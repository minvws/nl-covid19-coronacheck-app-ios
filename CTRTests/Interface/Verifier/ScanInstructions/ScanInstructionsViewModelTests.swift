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

	override func setUp() {
		super.setUp()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
	}

	func test_finishScanInstructions_callsCoordinator() {

		// Arrange
		sut = ScanInstructionsViewModel(
			coordinator: coordinatorSpy, pages: [], userSettings: userSettingsSpy
		)

		// Act
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
		sut.finishScanInstructions()

		// Assert
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
	}

	func test_userTappedBackOnFirstPage_callsCoordinator() {

		// Arrange
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy, pages: [], userSettings: userSettingsSpy)

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
				image: I.newScanInstructions.redScreenNowWhat(),
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy, pages: pages, userSettings: userSettingsSpy)

		// Act
		let viewController = sut.scanInstructionsViewController(forPage: pages[0])

		// Assert
		viewController.assertImage()
	}

	func test_skipButtonShownWhenUserFirstTimeExceptOnLastPage() {
		// Arrange
		userSettingsSpy.stubbedScanInstructionShown = false
		
		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				image: I.newScanInstructions.redScreenNowWhat(),
				step: .redScreenNowWhat
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				image: I.newScanInstructions.redScreenNowWhat(),
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy, pages: pages, userSettings: userSettingsSpy)

		// Assert
		expect(self.sut.shouldShowSkipButton(forPageIndex: 0)) == true
		expect(self.self.sut.shouldShowSkipButton(forPageIndex: 1)) == false
	}

	func test_skipButtonNotShownWhenNotFirstViewingOfInstructions() {
		userSettingsSpy.stubbedScanInstructionShown = true

		// Arrange
		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				image: I.newScanInstructions.redScreenNowWhat(),
				step: .redScreenNowWhat
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				image: I.newScanInstructions.redScreenNowWhat(),
				step: .redScreenNowWhat
			)
		]
		sut = ScanInstructionsViewModel(coordinator: coordinatorSpy, pages: pages, userSettings: userSettingsSpy)

		// Assert
		expect(self.sut.shouldShowSkipButton(forPageIndex: 0)) == false
		expect(self.self.sut.shouldShowSkipButton(forPageIndex: 1)) == false
	}
}
