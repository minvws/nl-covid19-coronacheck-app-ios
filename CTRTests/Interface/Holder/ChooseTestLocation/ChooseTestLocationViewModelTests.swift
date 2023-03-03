/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
@testable import Resources
import Shared
import ReusableViews

class ChooseTestLocationViewModelTests: XCTestCase {

	var sut: ChooseTestLocationViewModel!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = ChooseTestLocationViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_loadedState() {
		// Arrange

		// Act

		// Assert
		expect(self.sut.title.value) == L.holderLocationTitle()
		expect(self.sut.message.value) == L.holderLocationMessage()
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.bottomButton.value) != nil
	}
	
	func test_createNegativeTestFromGGD() {
		// Arrange

		// Act
		self.sut.optionModels.value[0].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateANegativeTestQRFromGGD) == true
	}
	
	func test_createNegativeTest() {
		// Arrange

		// Act
		self.sut.optionModels.value[1].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateANegativeTestQR) == true
	}
	
	func test_notTested() {
		// Arrange

		// Act
		self.sut.bottomButton.value?.action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInfoAboutGettingTested) == true
	}
}
