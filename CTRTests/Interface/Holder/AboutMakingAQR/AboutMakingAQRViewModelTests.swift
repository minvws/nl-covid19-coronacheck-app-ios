/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class AboutMakingAQRViewModelTests: XCTestCase {

	var sut: AboutMakingAQRViewModel!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = AboutMakingAQRViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_loadedState() {
		// Arrange

		// Act

		// Assert
		expect(self.sut.title).toNot(beEmpty())
		expect(self.sut.header).toNot(beEmpty())
		expect(self.sut.body).toNot(beEmpty())
		expect(self.sut.image) == .create
	}

	func test_userTouchedURL_triggersCoordinator() {
		// Arrange
		let testURL = URL(string: "http://sanjose.com")!

		// Act
		sut.userTouchedURL(testURL)

		// Assert
		expect(self.coordinatorDelegateSpy.invokedOpenUrlParameters?.url) == testURL
	}

	func test_userTappedNext_triggersCoordinator() {
		// Arrange
		// Act
		sut.userTappedNext()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateAQR) == true
	}
}
