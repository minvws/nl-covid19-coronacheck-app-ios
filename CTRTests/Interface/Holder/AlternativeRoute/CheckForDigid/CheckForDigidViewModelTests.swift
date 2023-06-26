/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

class CheckForDigidViewModelTests: XCTestCase {
	
	var sut: CheckForDigidViewModel!
	var coordinatorDelegateSpy: AlternativeRouteCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = AlternativeRouteCoordinatorDelegateSpy()
		sut = CheckForDigidViewModel(coordinator: coordinatorDelegateSpy)
	}
	
	func test_loadedState() {
		
		// Arrange
		
		// Act
		
		// Assert
		expect(self.sut.title.value) == L.holder_noDigiD_title()
		expect(self.sut.message.value) == L.holder_noDigiD_message()
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.bottomButton.value) == nil
	}
	
	func test_requestDigid() {

		// Arrange

		// Act
		self.sut.optionModels.value[0].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedOpenUrl) == true
		expect(self.coordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_noDigiD_url()
	}

	func test_doesNotHaveDigid() {

		// Arrange

		// Act
		self.sut.optionModels.value[1].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCheckForBSN) == true
	}
}
