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

	var sut: IdentitySelectionViewModel!

	var coordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegateSpy!
	var dataSourceSpy: IdentitySelectionDataSourceSpy!
	
	override func setUp() {
		super.setUp()

		dataSourceSpy = IdentitySelectionDataSourceSpy()
		coordinatorDelegateSpy = FuzzyMatchingCoordinatorDelegateSpy()
		sut = IdentitySelectionViewModel(
			coordinatorDelegate: coordinatorDelegateSpy,
			dataSource: dataSourceSpy,
			nestedBlobIds: []
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

class IdentitySelectionDataSourceSpy: IdentitySelectionDataSourceProtocol {

	var invokedGetIdentityInformation = false
	var invokedGetIdentityInformationCount = 0
	var invokedGetIdentityInformationParameters: (nestedBlobIds: [[String]], Void)?
	var invokedGetIdentityInformationParametersList = [(nestedBlobIds: [[String]], Void)]()
	var stubbedGetIdentityInformationResult: [(blobIds: [String], name: String, eventCountInformation: String)]! = []

	func getIdentityInformation(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)] {
		invokedGetIdentityInformation = true
		invokedGetIdentityInformationCount += 1
		invokedGetIdentityInformationParameters = (nestedBlobIds, ())
		invokedGetIdentityInformationParametersList.append((nestedBlobIds, ()))
		return stubbedGetIdentityInformationResult
	}
}
