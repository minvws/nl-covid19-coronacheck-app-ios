//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class ChooseQRCodeTypeViewModelTests: XCTestCase {

	var sut: ChooseQRCodeTypeViewModel!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = ChooseQRCodeTypeViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_loadedState() {
		// Arrange

		// Act

		// Assert
		expect(self.sut.title) == .holderChooseQRCodeTypeTitle
		expect(self.sut.message) == .holderChooseQRCodeTypeMessage(testHoursValidity: 40, vaccineDaysValidity: 365)
	}
}
