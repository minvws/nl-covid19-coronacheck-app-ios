/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		expect(self.sut.title) == L.holderChooseqrcodetypeTitle()
		expect(self.sut.message) == L.holderChooseqrcodetypeMessage()
		expect(self.sut.buttonModels).to(haveCount(3))
	}
}
