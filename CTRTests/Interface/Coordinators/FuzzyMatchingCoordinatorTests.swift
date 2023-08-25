/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class FuzzyMatchingCoordinatorTests: XCTestCase {
	
	override func setUp() {
		
		super.setUp()
		_ = setupEnvironmentSpies()
	}
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (FuzzyMatchingCoordinator, NavigationControllerSpy, FuzzyMatchingOnboardingFactorySpy, FuzzyMatchingFlowSpy) {
		
		let navigationSpy = NavigationControllerSpy()
		let factorySpy = FuzzyMatchingOnboardingFactorySpy()
		let delegateSpy = FuzzyMatchingFlowSpy()
		
		let sut = FuzzyMatchingCoordinator(
			navigationController: navigationSpy,
			matchingBlobIds: [[]],
			onboardingFactory: factorySpy,
			delegate: delegateSpy
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, factorySpy, delegateSpy)
	}
	
	// MARK: - Tests
	
	/// Test the start method with update page
	func test_start_shouldStartOnboarding() {
		
		// Given
		let (sut, navigationSpy, factorySpy, delegateSpy) = makeSUT()
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_onboardingFinished_shouldInvokeListIdentities() {
		
		// Given
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ListIdentitySelectionViewController) == true
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let (sut, _, _, _) = makeSUT()
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
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
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
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userWishesToSeeIdentitySelectionDetails() {
		
		// Given
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
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
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userHasSelectedIdentityGroup() {
		
		// Given
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
		
		// When
		sut.userHasSelectedIdentityGroup(selectedBlobIds: [])
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is SendIdentitySelectionViewController) == true
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userWishesToSeeSuccess() {
		
		// Given
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
		let name = "Rool"
		
		// When
		sut.userWishesToSeeSuccess(name: name)
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ContentViewController) == true
		let viewModel = (navigationSpy.viewControllers.first as? ContentViewController)?.viewModel
		
		expect(viewModel?.content.value.title) == L.holder_identitySelection_success_title()
		expect(viewModel?.content.value.body) == L.holder_identitySelection_success_body(name)
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userWishesToSeeSuccess_invokedAction_shouldInvokeFlowDidFinish() {
		
		// Given
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
		let name = "Rool"
		sut.userWishesToSeeSuccess(name: name)
		let viewModel = (navigationSpy.viewControllers.first as? ContentViewController)?.viewModel as? ContentViewModel
		
		// When
		viewModel?.content.value.primaryAction?()
		
		// Then
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == true
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_userHasStoppedTheFlow() {
		
		// Given
		let (sut, _, _, delegateSpy) = makeSUT()
		
		// When
		sut.userHasStoppedTheFlow()
		
		// Then
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == true
	}
	
	func test_userHasFinishedTheFlow() {
		
		// Given
		let (sut, _, _, delegateSpy) = makeSUT()
		
		// When
		sut.userHasFinishedTheFlow()
		
		// Then
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == true
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_presentError() {
		
		// Given
		let (sut, navigationSpy, _, delegateSpy) = makeSUT()
		let content = Content(title: "test")
		
		// When
		sut.presentError(content: content, backAction: nil)
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ContentViewController) == true
		let viewModel = (navigationSpy.viewControllers.first as? ContentViewController)?.viewModel
		
		expect(viewModel?.content.value.title) == "test"
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_restartFlow_noOnboardingInNavigationStack() {
		
		// Given
		let (sut, navigationSpy, factorySpy, delegateSpy) = makeSUT()
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]
		
		// When
		sut.restartFlow(matchingBlobIds: [["123"]])
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		expect(navigationSpy.invokedPopToViewController) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
	}
	
	func test_restartFlow_onboardingInNavigationStack() {
		
		// Given
		let (sut, navigationSpy, factorySpy, delegateSpy) = makeSUT()
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
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
		
		navigationSpy.viewControllers = [
			viewController
		]
		
		// When
		sut.restartFlow(matchingBlobIds: [["123"]])
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		expect(navigationSpy.invokedPopToViewController) == true
		expect(delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
		expect(delegateSpy.invokedFuzzyMatchingFlowDidStop) == false
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
	
	var invokedFuzzyMatchingUserBackedOutOfFlow = false
	var invokedFuzzyMatchingUserBackedOutOfFlowCount = 0
	
	func fuzzyMatchingUserBackedOutOfFlow() {
		invokedFuzzyMatchingUserBackedOutOfFlow = true
		invokedFuzzyMatchingUserBackedOutOfFlowCount += 1
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
