/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI
import XCTest
@testable import CTR
import Nimble
import TestingShared

class ShowQRViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ShowQRViewController!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var viewModel: ShowQRViewModel!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	// MARK: Test lifecycle

	override func setUpWithError() throws {

		try super.setUpWithError()
		environmentSpies = setupEnvironmentSpies()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content_euGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.navigationInfoView.nextButton.isHidden) == true
		expect(self.sut.sceneView.navigationInfoView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == true
	}

	/// Test all the default content
	func test_content_euGreenCard_withThirdPartyApp() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: "RollerDiscoParties"
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.returnToThirdPartyAppButton.isHidden) == true
		expect(self.sut.sceneView.navigationInfoView.nextButton.isHidden) == true
		expect(self.sut.sceneView.navigationInfoView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == true
		expect(self.sut.sceneView.pageControl.numberOfPages) == 1
	}

	func test_content_euGreenCard_multipleGreenCards_noDosageInformation_shouldShowFirstGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard, greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.navigationInfoView.nextButton.isHidden) == false
		expect(self.sut.sceneView.navigationInfoView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == false
		expect(self.sut.sceneView.pageControl.currentPageIndex) == 0
		expect(self.sut.sceneView.pageControl.numberOfPages) == 2
	}

	func test_nextButtonTapped_euGreenCard_multipleGreenCards() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard, greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.didTapNextButton()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.navigationInfoView.nextButton.isHidden).toEventually(beTrue())
		expect(self.sut.sceneView.navigationInfoView.previousButton.isHidden).toEventually(beFalse())
		expect(self.sut.sceneView.pageControl.isHidden) == false
		expect(self.sut.sceneView.pageControl.currentPageIndex).toEventually(equal(1))
		expect(self.sut.sceneView.pageControl.numberOfPages) == 2
	}
}
