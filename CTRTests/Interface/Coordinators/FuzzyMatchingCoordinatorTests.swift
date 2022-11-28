/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Transport

class FuzzyMatchingCoordinatorTests: XCTestCase {
	
	var sut: FuzzyMatchingCoordinator!

	var navigationSpy: NavigationControllerSpy!
	
	var factorySpy: FuzzyMatchingOnboardingFactorySpy!

	var delegateSpy: FuzzyMatchingFlowSpy!

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		factorySpy = FuzzyMatchingOnboardingFactorySpy()
		delegateSpy = FuzzyMatchingFlowSpy()
		_ = setupEnvironmentSpies()
		sut = FuzzyMatchingCoordinator(
			navigationController: navigationSpy,
			matchingBlobIds: [[]],
			onboardingFactory: factorySpy,
			delegate: delegateSpy
		)
	}

	// MARK: - Tests

	/// Test the start method with update page
	func test_start_shouldStartOnboarding() {

		// Given
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			image: nil,
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]

		// When
		sut.start()

		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}

	func test_onboardingFinished_shouldInvokeListIdentities() {
		
		// Given
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is ListIdentitySelectionViewController) == true
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let universalLink = UniversalLink.redeemHolderToken(
			requestToken: RequestToken(
				token: "STXT2VF3389TJ2",
				protocolVersion: "3.0",
				providerIdentifier: "XXX"
			)
		)
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
	}
	
	func test_userWishesMoreInfoAboutWhy() {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutWhy()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel: BottomSheetContentViewModel? = ((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel
		
		expect(viewModel?.content.title) == L.holder_fuzzyMatching_why_title()
		expect(viewModel?.content.body) == L.holder_fuzzyMatching_why_body()
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userWishesToSeeIdentitySelectionDetails() {
		
		// Given
		let details = IdentitySelectionDetails(name: "Test", details: [["vaccination", "today"]])
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesToSeeIdentitySelectionDetails(details)
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel: IdentitySelectionDetailsViewModel? = ((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? IdentitySelectionDetailsViewController)?.viewModel
		expect(viewModel?.message.value) == "Deze gegevens horen bij de naam <b>Test</b>"
		expect(viewModel?.details.value).to(haveCount(1))
		expect(viewModel?.details.value.first).to(haveCount(2))
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userHasSelectedIdentityGroup() {
		
		// Given
		
		// When
		sut.userHasSelectedIdentityGroup(selectedBlobIds: [])
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is SendIdentitySelectionViewController) == true
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userWishesToSeeSuccess() {
		
		// Given
		let name = "Rool"
		
		// When
		sut.userWishesToSeeSuccess(name: name)
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is ContentViewController) == true
		let viewModel = (self.navigationSpy.viewControllers.first as? ContentViewController)?.viewModel
		
		expect(viewModel?.content.title) == L.holder_identitySelection_success_title()
		expect(viewModel?.content.body) == L.holder_identitySelection_success_body(name)
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userWishesToSeeSuccess_invokedAction_shouldInvokeFlowDidFinish() {
		
		// Given
		let name = "Rool"
		sut.userWishesToSeeSuccess(name: name)
		let viewModel = (self.navigationSpy.viewControllers.first as? ContentViewController)?.viewModel as? ContentViewModel
		
		// When
		viewModel?.content.primaryAction?()
		
		// Then
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == true
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userHasStoppedTheFlow() {
		
		// Given
		
		// When
		sut.userHasStoppedTheFlow()
		
		// Then
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == true
	}
	
	func test_userHasFinishedTheFlow() {
		
		// Given
		
		// When
		sut.userHasFinishedTheFlow()
		
		// Then
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == true
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_presentError() {
		
		// Given
		let content = Content(title: "test")
		
		// When
		sut.presentError(content: content, backAction: nil)
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is ContentViewController) == true
		let viewModel = (self.navigationSpy.viewControllers.first as? ContentViewController)?.viewModel
		
		expect(viewModel?.content.title) == "test"
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_restartFlow_noOnboardingInNavigationStack() {
		
		// Given
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			image: nil,
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]

		// When
		sut.restartFlow(matchingBlobIds: [["123"]])

		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_restartFlow_onboardingInNavigationStack() {
		
		// Given
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			image: nil,
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]
		let viewController = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: sut,
				pages: factorySpy.stubbedPages,
				itemsShouldShowWithFullWidthHeaderImage: true,
				shouldShowWithVWSRibbon: false
			),
			allowsPreviousPageButton: true,
			allowsCloseButton: false,
			allowsNextPageButton: true
		)
		
		self.navigationSpy.viewControllers = [
			viewController
		]

		// When
		sut.restartFlow(matchingBlobIds: [["123"]])

		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
}

class FuzzyMatchingFlowSpy: FuzzyMatchingFlowDelegate {

	var invokedFuzzyMatchingFlowDidStop = false
	var invokedFuzzyMatchingFlowDidStopCount = 0

	func fuzzyMatchingFlowDidStop() {
		invokedFuzzyMatchingFlowDidStop = true
		invokedFuzzyMatchingFlowDidStopCount += 1
	}

	var invokedFuzzyMatchingFlowDidFinish = false
	var invokedFuzzyMatchingFlowDidFinishCount = 0

	func fuzzyMatchingFlowDidFinish() {
		invokedFuzzyMatchingFlowDidFinish = true
		invokedFuzzyMatchingFlowDidFinishCount += 1
	}
}

class FuzzyMatchingOnboardingFactorySpy: FuzzyMatchingOnboardingFactoryProtocol {

	var invokedPagesGetter = false
	var invokedPagesGetterCount = 0
	var stubbedPages: [PagedAnnoucementItem]! = []

	var pages: [PagedAnnoucementItem] {
		invokedPagesGetter = true
		invokedPagesGetterCount += 1
		return stubbedPages
	}
}
