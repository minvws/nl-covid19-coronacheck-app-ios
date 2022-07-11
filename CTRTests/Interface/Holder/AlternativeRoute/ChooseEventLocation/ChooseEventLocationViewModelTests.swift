/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class ChooseEventLocationViewModelTests: XCTestCase {
	
	var sut: ChooseEventLocationViewModel!
	var coordinatorDelegateSpy: AlternativeRouteCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = AlternativeRouteCoordinatorDelegateSpy()
		sut = ChooseEventLocationViewModel(coordinator: coordinatorDelegateSpy, eventMode: .vaccination)
	}
	
	func test_loadedState() {
		
		// Arrange
		
		// Act
		
		// Assert
		expect(self.sut.title.value) == L.holder_chooseEventLocation_title(L.holder_contactProviderHelpdesk_vaccinated())
		expect(self.sut.message.value).to(beNil())
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.bottomButton.value).to(beNil())
	}
	
	func test_loadedState_negativeTest() {
		
		// Arrange
		sut = ChooseEventLocationViewModel(coordinator: coordinatorDelegateSpy, eventMode: .test)
		
		// Act
		
		// Assert
		expect(self.sut.title.value) == L.holder_chooseEventLocation_title(L.holder_contactProviderHelpdesk_tested())
		expect(self.sut.message.value).to(beNil())
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.bottomButton.value).to(beNil())
	}
	
	func test_goToGGDPortal() {

		// Arrange

		// Act
		self.sut.optionModels.value[0].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishedToGoToGGDPortal) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToContactHelpDeksWithoutBSN) == false
	}

	func test_contactHelpdesk() {

		// Arrange

		// Act
		self.sut.optionModels.value[1].action()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishedToGoToGGDPortal) == false
		expect(self.coordinatorDelegateSpy.invokedUserWishesToContactHelpDeksWithoutBSN) == true
	}
}
