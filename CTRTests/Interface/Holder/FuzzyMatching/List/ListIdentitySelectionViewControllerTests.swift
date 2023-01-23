/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
import ViewControllerPresentationSpy
@testable import CTR
import Shared

final class ListIdentitySelectionViewControllerTests: XCTestCase {
	
	private var sut: ListIdentitySelectionViewController!
	private var window = UIWindow()

	private var coordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegateSpy!
	private var dataSourceSpy: IdentitySelectionDataSourceSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		dataSourceSpy = IdentitySelectionDataSourceSpy()
		coordinatorDelegateSpy = FuzzyMatchingCoordinatorDelegateSpy()
		window = UIWindow()

		dataSourceSpy.stubbedGetIdentityInformationResult = [
			(blobIds: ["123"], name: "Rool", eventCountInformation: "1 vaccinatie"),
			(blobIds: ["456"], name: "Rolus", eventCountInformation: "1 negatieve test")
		]
		dataSourceSpy.stubbedGetEventOveriewResult = [["Vaccination", "Today"]]
		
		sut = ListIdentitySelectionViewController(
			viewModel: ListIdentitySelectionViewModel(
				coordinatorDelegate: coordinatorDelegateSpy,
				dataSource: dataSourceSpy,
				matchingBlobIds: []
			)
		)
	}
	
	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	func test_listTwoItems() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_identitySelection_title()
		expect(self.sut.sceneView.header) == L.holder_identitySelection_message()
		expect(self.sut.sceneView.moreButtonTitle) == L.holder_identitySelection_why()
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.holder_identitySelection_actionTitle()
		expect(self.sut.sceneView.errorMessage) == nil
		expect(self.sut.sceneView.selectionStackView.arrangedSubviews).to(haveCount(2))

		sut.assertImage()
	}

	func test_readMore() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.readMoreCommand?()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInfoAboutWhy) == true
	}

	func test_primaryAction_noSelectedItems() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.footerButtonView.primaryButtonTappedCommand?()
		
		// Then
		expect(self.sut.sceneView.errorMessage) == L.holder_identitySelection_error_makeAChoice()
		
		sut.assertImage()
	}
	
	func test_selectItem() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.selectionStackView.arrangedSubviews.first as? IdentityControlView)?.selectionButtonCommand?()
		
		// Then
		expect(self.sut.viewModel.selectedBlobIds) == ["123"]
		
		sut.assertImage()
	}
	
	func test_showItem() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.selectionStackView.arrangedSubviews.first as? IdentityControlView)?.actionButtonCommand?()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeIdentitySelectionDetails) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeIdentitySelectionDetailsParameters?.identitySelectionDetails) == IdentitySelectionDetails(name: "Rool", details: [["Vaccination", "Today"]])
	}
	
	func test_skipButtonPressed() {
		
		// Given
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.onSkip()
		
		// Then
		alertVerifier.verify(
			title: L.holder_identitySelection_skipAlert_title(),
			message: L.holder_identitySelection_skipAlert_body(),
			animated: true,
			actions: [
				.destructive(L.holder_identitySelection_skipAlert_action()),
				.cancel(L.general_cancel())
			]
		)
	}
	
	func test_skipButtonPressed_okAction() throws {
		
		// Given
		let alertVerifier = AlertVerifier()
		loadView()
		sut.onSkip()
		
		// When
		try alertVerifier.executeAction(forButton: L.holder_identitySelection_skipAlert_action())
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserHasStoppedTheFlow) == true
	}
}
