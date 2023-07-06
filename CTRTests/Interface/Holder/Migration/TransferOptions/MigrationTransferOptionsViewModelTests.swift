/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import XCTest
import Nimble
@testable import CTR

class MigrationTransferOptionsViewModelTests: XCTestCase {

	var sut: MigrationTransferOptionsViewModel!
	var coordinatorDelegateSpy: MigrationCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = MigrationCoordinatorDelegateSpy()
		sut = MigrationTransferOptionsViewModel(coordinatorDelegateSpy)
	}

	func test_loadedState() {
		// Arrange

		// Act

		// Assert
		expect(self.sut.title.value) == L.holder_startMigration_title()
		expect(self.sut.message.value) == L.holder_startMigration_message()
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.bottomButton.value) == nil
	}
	
	func test_toOtherDevice() {
		// Arrange

		// Act
		self.sut.optionModels.value[0].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeToOtherDeviceInstructions) == true
	}
	
	func test_toThisDevice() {
		// Arrange

		// Act
		self.sut.optionModels.value[1].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeToThisDeviceInstructions) == true
	}
}
