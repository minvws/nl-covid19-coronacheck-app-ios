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

class PaperProofCoordinatorTests: XCTestCase {
	
	override func setUp() {
		
		super.setUp()
		_ = setupEnvironmentSpies()
	}
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (PaperProofCoordinator, NavigationControllerSpy, PaperProofFlowDelegateSpy) {
			
		let navigationSpy = NavigationControllerSpy()
		let flowSpy = PaperProofFlowDelegateSpy()
		let sut = PaperProofCoordinator(navigationController: navigationSpy, delegate: flowSpy)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, flowSpy)
	}
	
	// MARK: - Tests
	
	func test_start() throws {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentWithImageViewController) == true
		expect((navigationSpy.viewControllers.last as? ContentWithImageViewController)?.viewModel)
					.to(beAnInstanceOf(PaperProofStartScanningViewModel.self))
	}
	
	func test_consumeLink() {
		
		// Given
		let (sut, _, _) = makeSUT()
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let result = sut.consume(universalLink: universalLink)
		
		// Then
		expect(result) == false
	}

	func test_userWishesToEnterToken() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		
		// When
		sut.userWishesToEnterToken()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(sut.token) == nil
		expect(sut.scannedDCC) == nil
	}

	func test_userDidScanDCC() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		
		// When
		sut.userDidScanDCC("test")

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 0
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(sut.token) == nil
		expect(sut.scannedDCC) == "test"
	}
	
	func test_userDidSubmitPaperProofToken() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		
		// When
		sut.userDidSubmitPaperProofToken(token: "test")

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 0
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(sut.token) == "test"
		expect(sut.scannedDCC) == nil
	}

	func test_userWantsToGoBackToDashboard() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		sut.token = "test"
		sut.scannedDCC = "test"

		// When
		sut.userWantsToGoBackToDashboard()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 0
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(sut.token) == nil
		expect(sut.scannedDCC) == nil
	}

	func test_userWishesToScanCertificate() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		
		// When
		sut.userWishesToScanCertificate()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(sut.token) == nil
		expect(sut.scannedDCC) == nil
	}

	func test_userWishesToCreateACertificate_tokenNil_scannedDCCNil() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		sut.token = nil
		sut.scannedDCC = nil

		// When
		sut.userWishesToCreateACertificate()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 0
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
	}
	
	func test_userWishesToCreateACertificate_tokenNotNil_scannedDCCNil() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		sut.token = "test"
		sut.scannedDCC = nil

		// When
		sut.userWishesToCreateACertificate()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 0
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
	}
	
	func test_userWishesToCreateACertificate_tokenNotNil_scannedDCCNotNil() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		sut.token = "test"
		sut.scannedDCC = "test"

		// When
		sut.userWishesToCreateACertificate()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
	}

	func test_userWishesToSeeScannedEvent() {

		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let remoteEvent = RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: EventFlow.Identity.fakeIdentity,
				status: .complete
			),
			signedResponse: nil
		)

		// When
		sut.userWishesToSeeScannedEvent(remoteEvent)

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
	}
	
	func test_eventFlowDidCancel() {

		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		sut.token = "test"
		sut.scannedDCC = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		navigationSpy.viewControllers = [
			ContentWithImageViewController(viewModel: PaperProofStartScanningViewModel(coordinator: sut)),
			PaperProofInputCouplingCodeViewController(viewModel: PaperProofInputCouplingCodeViewModel(coordinator: sut)),
			PaperProofScanViewController(viewModel: PaperProofScanViewModel(coordinator: sut))
		]

		// When
		sut.eventFlowDidCancel()

		// Then
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(sut.token) == nil
		expect(sut.scannedDCC) == nil
		expect(sut.childCoordinators).to((haveCount(0)))
		expect(navigationSpy.invokedPopToViewController) == true
		expect(navigationSpy.viewControllers).to(haveCount(1))
	}

	func test_eventFlowDidComplete() {

		// Given
		let (sut, _, flowSpy) = makeSUT()
		sut.token = "test"
		sut.scannedDCC = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))

		// When
		sut.eventFlowDidComplete()

		// Then
		expect(flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(sut.token) == nil
		expect(sut.scannedDCC) == nil
		expect(sut.childCoordinators).to((haveCount(0)))
	}
	
	func test_userWishesMoreInformationOnNoInputToken() throws {

		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.userWishesMoreInformationOnNoInputToken()

		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.holderPaperproofNotokenTitle()
		expect(viewModel.content.value.body) == L.holderPaperproofNotokenMessage()
	}
	
	func test_userWishesMoreInformationOnWhichProofsCanBeUsed() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInformationOnWhichProofsCanBeUsed()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel: BottomSheetContentViewModel? = ((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel
		
		expect(viewModel?.content.title) == L.holder_paperproof_whichProofsCanBeUsed_title()
		expect(viewModel?.content.body) == L.holder_paperproof_whichProofsCanBeUsed_body()
	}
	
	func test_displayError() throws {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.displayError(content: content, backAction: {})
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_displayErrorForPaperProofCheck() throws {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.displayErrorForPaperProofCheck(content: content)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_userWishesToCancelPaperProofFlow() {
		
		// Given
		let (sut, navigationSpy, flowSpy) = makeSUT()
		
		// When
		sut.userWishesToCancelPaperProofFlow()
		
		// Then
		expect(navigationSpy.invokedPopViewController) == true
		expect(flowSpy.invokedAddPaperProofFlowDidCancel) == true
	}
	
	func test_userWantsToGoBackToEnterToken() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		navigationSpy.viewControllers = [
			PaperProofScanViewController(viewModel: PaperProofScanViewModel(coordinator: sut)),
			PaperProofInputCouplingCodeViewController(viewModel: PaperProofInputCouplingCodeViewModel(coordinator: sut)),
			PaperProofScanViewController(viewModel: PaperProofScanViewModel(coordinator: sut))
		]
		expect(navigationSpy.viewControllers).to(haveCount(3))
		
		// When
		sut.userWantsToGoBackToEnterToken()
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == true
		expect(navigationSpy.viewControllers).to(haveCount(2))
	}
}

class PaperProofFlowDelegateSpy: PaperProofFlowDelegate {

	var invokedAddPaperProofFlowDidCancel = false
	var invokedAddPaperProofFlowDidCancelCount = 0

	func addPaperProofFlowDidCancel() {
		invokedAddPaperProofFlowDidCancel = true
		invokedAddPaperProofFlowDidCancelCount += 1
	}

	var invokedAddPaperProofFlowDidFinish = false
	var invokedAddPaperProofFlowDidFinishCount = 0

	func addPaperProofFlowDidFinish() {
		invokedAddPaperProofFlowDidFinish = true
		invokedAddPaperProofFlowDidFinishCount += 1
	}

	var invokedSwitchToAddRegularProof = false
	var invokedSwitchToAddRegularProofCount = 0

	func switchToAddRegularProof() {
		invokedSwitchToAddRegularProof = true
		invokedSwitchToAddRegularProofCount += 1
	}
}
