/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

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
		expect(self.sut.title) == L.holderLocationTitle()
		expect(self.sut.message) == L.holderLocationMessage()
		expect(self.sut.buttonModels).to(haveCount(2))
		expect(self.sut.bottomButton).toNot(beNil())
	}
}
