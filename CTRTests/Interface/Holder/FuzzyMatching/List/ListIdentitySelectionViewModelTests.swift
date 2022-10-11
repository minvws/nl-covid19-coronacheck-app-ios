/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

final class ListIdentitySelectionViewModelTests: XCTestCase {

	var sut: ListIdentitySelectionViewModel!

	var coordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegateSpy!
	var dataSourceSpy: IdentitySelectionDataSourceSpy!
	
	override func setUp() {
		super.setUp()

		dataSourceSpy = IdentitySelectionDataSourceSpy()
		coordinatorDelegateSpy = FuzzyMatchingCoordinatorDelegateSpy()
	}
	
	func setupSut() {
		
		sut = ListIdentitySelectionViewModel(
			coordinatorDelegate: coordinatorDelegateSpy,
			dataSource: dataSourceSpy,
			matchingBlobIds: []
		)
	}

	func test_userWishesToSkip() {
		
		// Given
		setupSut()
		
		// When
		sut.userWishesToSkip()
		
		// Then
		expect(self.sut.alert.value) != nil
	}
	
	func test_userWishedToReadMore() {
		
		// Given
		setupSut()
		
		// When
		sut.userWishedToReadMore()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInfoAboutWhy) == true
	}
	
	func test_list_noItems() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = []
		
		// When
		setupSut()

		// Then
		expect(self.sut.title.value) == L.holder_identitySelection_title()
		expect(self.sut.message.value) == L.holder_identitySelection_message()
		expect(self.sut.whyTitle.value) == L.holder_identitySelection_why()
		expect(self.sut.actionTitle.value) == L.holder_identitySelection_actionTitle()
		expect(self.sut.errorMessage.value) == nil
		expect(self.sut.alert.value) == nil
		expect(self.sut.identityItems.value).to(beEmpty())
	}
	
	func test_list_oneItem() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [(blobIds: ["123"], name: "Rool", eventCountInformation: "test")]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		
		// When
		setupSut()

		// Then
		expect(self.sut.title.value) == L.holder_identitySelection_title()
		expect(self.sut.message.value) == L.holder_identitySelection_message()
		expect(self.sut.whyTitle.value) == L.holder_identitySelection_why()
		expect(self.sut.actionTitle.value) == L.holder_identitySelection_actionTitle()
		expect(self.sut.errorMessage.value) == nil
		expect(self.sut.alert.value) == nil
		expect(self.sut.identityItems.value).to(haveCount(1))
	}
	
	func test_list_twoItems() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		
		// When
		setupSut()

		// Then
		expect(self.sut.title.value) == L.holder_identitySelection_title()
		expect(self.sut.message.value) == L.holder_identitySelection_message()
		expect(self.sut.whyTitle.value) == L.holder_identitySelection_why()
		expect(self.sut.actionTitle.value) == L.holder_identitySelection_actionTitle()
		expect(self.sut.errorMessage.value) == nil
		expect(self.sut.alert.value) == nil
		expect(self.sut.identityItems.value).to(haveCount(2))
	}
	
	func test_list_twoItems_showDetails_firstItem() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		setupSut()
		
		// When
		self.sut.identityItems.value.first?.onShowDetails()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeIdentitySelectionDetails) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeIdentitySelectionDetailsParameters?.identitySelectionDetails) == IdentitySelectionDetails(name: "Rool", details: [["Vaccination", "Today"]])
	}
	
	func test_list_twoItems_showDetails_lastItem() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		setupSut()
		
		// When
		self.sut.identityItems.value.last?.onShowDetails()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeIdentitySelectionDetails) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeIdentitySelectionDetailsParameters?.identitySelectionDetails) == IdentitySelectionDetails(name: "Rolus", details: [["Vaccination", "Today"]])
	}
	
	func test_list_twoItems_selectFirstItem() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		setupSut()
		
		// When
		self.sut.identityItems.value.first?.onSelectIdentity()

		// Then
		expect(self.sut.selectedBlobIds) == ["123"]
		expect(self.sut.identityItems.value.first?.state.value) == .selected
		expect(self.sut.identityItems.value.last?.state.value) == .warning(L.holder_identitySelection_error_willBeRemoved())
	}
	
	func test_list_twoItems_selectLastItem() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		setupSut()
		
		// When
		self.sut.identityItems.value.last?.onSelectIdentity()

		// Then
		expect(self.sut.selectedBlobIds) == ["456"]
		expect(self.sut.identityItems.value.first?.state.value) == .warning(L.holder_identitySelection_error_willBeRemoved())
		expect(self.sut.identityItems.value.last?.state.value) == .selected
	}
	
	func test_saveItems_noSelectedItems_shouldShowError() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		setupSut()
		
		// When
		sut.userWishesToSaveEvents()
		
		// Then
		expect(self.sut.errorMessage.value) == L.holder_identitySelection_error_makeAChoice()
		expect(self.sut.identityItems.value.first?.state.value) == .selectionError
		expect(self.sut.identityItems.value.last?.state.value) == .selectionError
		expect(self.coordinatorDelegateSpy.invokedUserHasSelectedIdentityGroup) == false
	}
	
	func test_saveItems_selectedLastItem_shouldInvokeCoordinator() {
		
		// Given
		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "test"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		setupSut()
		self.sut.identityItems.value.last?.onSelectIdentity()
		
		// When
		sut.userWishesToSaveEvents()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserHasSelectedIdentityGroup) == true
	}
}
