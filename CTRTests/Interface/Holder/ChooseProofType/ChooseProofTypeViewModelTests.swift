/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class ChooseProofTypeViewModelTests: XCTestCase {

	var sut: ChooseProofTypeViewModel!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = ChooseProofTypeViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_loadedState() {
		// Arrange

		// Act

		// Assert
		expect(self.sut.title.value) == L.holderChooseqrcodetypeTitle()
		expect(self.sut.message.value) == L.holderChooseqrcodetypeMessage()
		expect(self.sut.optionModels.value).to(haveCount(3))
		expect(self.sut.bottomButton.value) == nil
	}
	
	func test_createVaccinationQR() {
		// Arrange

		// Act
		self.sut.optionModels.value[0].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateAVaccinationQR) == true
	}
	
	func test_createRecoveryQR() {
		// Arrange

		// Act
		self.sut.optionModels.value[1].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateARecoveryQR) == true
	}
	
	func test_createNegativeTest() {
		// Arrange

		// Act
		self.sut.optionModels.value[2].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToChooseTestLocation) == true
	}
}
