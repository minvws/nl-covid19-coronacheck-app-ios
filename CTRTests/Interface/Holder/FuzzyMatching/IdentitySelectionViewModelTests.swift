/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

final class IdentitySelectionViewModelTests: XCTestCase {

	var sut: ListIdentitySelectionViewModel!

	var coordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegateSpy!
	var dataSourceSpy: IdentitySelectionDataSourceSpy!
	
	override func setUp() {
		super.setUp()

		dataSourceSpy = IdentitySelectionDataSourceSpy()
		coordinatorDelegateSpy = FuzzyMatchingCoordinatorDelegateSpy()
		sut = ListIdentitySelectionViewModel(
			coordinatorDelegate: coordinatorDelegateSpy,
			dataSource: dataSourceSpy,
			matchingBlobIds: []
		)
	}

	func test_userWishesToSkip() {
		
		// Given
		
		// When
		sut.userWishesToSkip()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserHasFinishedTheFlow) == false
		expect(self.sut.alert.value) != nil
	}
	
	func test_userWishedToReadMore() {
		
		// Given
		
		// When
		sut.userWishedToReadMore()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInfoAboutWhy) == true
	}
}
