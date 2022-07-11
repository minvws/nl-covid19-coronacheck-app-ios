/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class CheckForBSNViewModelTests: XCTestCase {
	
	var sut: CheckForBSNViewModel!
	var coordinatorDelegateSpy: AlternativeRouteCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = AlternativeRouteCoordinatorDelegateSpy()
		sut = CheckForBSNViewModel(coordinator: coordinatorDelegateSpy, eventMode: .vaccination)
	}
	
	func test_loadedState() {
		
		// Arrange
		
		// Act
		
		// Assert
		expect(self.sut.title.value) == L.holder_checkForBSN_title()
		expect(self.sut.message.value) == L.holder_checkForBSN_message()
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.optionModels.value.first?.title) == L.holder_checkForBSN_buttonTitle_doesHaveBSN()
		expect(self.sut.optionModels.value.first?.subTitle) == L.holder_checkForBSN_buttonSubTitle_doesHaveBSN()
		expect(self.sut.optionModels.value.last?.title) == L.holder_checkForBSN_buttonTitle_doesNotHaveBSN()
		expect(self.sut.optionModels.value.last?.subTitle) == L.holder_checkForBSN_buttonSubTitle_doesNotHaveBSN_vaccinationFlow()
		expect(self.sut.bottomButton.value).to(beNil())
	}
	
	func test_loadedState_recovery() {
		
		// Arrange
		sut = CheckForBSNViewModel(coordinator: coordinatorDelegateSpy, eventMode: .recovery)
		
		// Act
		
		// Assert
		expect(self.sut.title.value) == L.holder_checkForBSN_title()
		expect(self.sut.message.value) == L.holder_checkForBSN_message()
		expect(self.sut.optionModels.value).to(haveCount(2))
		expect(self.sut.optionModels.value.first?.title) == L.holder_checkForBSN_buttonTitle_doesHaveBSN()
		expect(self.sut.optionModels.value.first?.subTitle) == L.holder_checkForBSN_buttonSubTitle_doesHaveBSN()
		expect(self.sut.optionModels.value.last?.title) == L.holder_checkForBSN_buttonTitle_doesNotHaveBSN()
		expect(self.sut.optionModels.value.last?.subTitle) == L.holder_checkForBSN_buttonSubTitle_doesNotHaveBSN_testFlow()
		expect(self.sut.bottomButton.value).to(beNil())
	}
	
	func test_doesHaveBSN() {
		
		// Arrange
		
		// Act
		self.sut.optionModels.value[0].action()
		
		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToContactHelpDeksWithBSN) == true
		expect(self.coordinatorDelegateSpy.invokedUserHasNoBSN) == false
	}
	
	func test_doesNotHaveBSN() {
		
		// Arrange
		
		// Act
		self.sut.optionModels.value[1].action()
		
		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesToContactHelpDeksWithBSN) == false
		expect(self.coordinatorDelegateSpy.invokedUserHasNoBSN) == true
	}
}
