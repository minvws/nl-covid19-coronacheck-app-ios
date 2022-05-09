/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class PaperProofCoordinatorTests: XCTestCase {

	private var sut: PaperProofCoordinator!
	private var environmentSpies: EnvironmentSpies!
	private var flowSpy: PaperProofFlowDelegateSpy!
	private var navigationSpy: NavigationControllerSpy!

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		flowSpy = PaperProofFlowDelegateSpy()
		navigationSpy = NavigationControllerSpy()

		sut = PaperProofCoordinator(navigationController: navigationSpy, delegate: flowSpy)
	}

	// MARK: - Tests
	
	func test_consumeLink() {
		
		// Given
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

		// When
		sut.userWishesToEnterToken()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC).to(beNil())
	}

	func test_userDidScanDCC() {

		// Given

		// When
		sut.userDidScanDCC("test")

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC) == "test"
	}
	
	func test_userDidSubmitPaperProofToken() {

		// Given

		// When
		sut.userDidSubmitPaperProofToken(token: "test")

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token) == "test"
		expect(self.sut.scannedDCC).to(beNil())
	}

	func test_userWantsToGoBackToDashboard() {

		// Given
		sut.token = "test"
		sut.scannedDCC = "test"

		// When
		sut.userWantsToGoBackToDashboard()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC).to(beNil())
	}

	func test_userWishesToScanCertificate() {

		// Given

		// When
		sut.userWishesToScanCertificate()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC).to(beNil())
	}

	func test_userWishesToCreateACertificate_tokenNil_scannedDCCNil() {

		// Given
		sut.token = nil
		sut.scannedDCC = nil

		// When
		sut.userWishesToCreateACertificate()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
	}
	
	func test_userWishesToCreateACertificate_tokenNotNil_scannedDCCNil() {

		// Given
		sut.token = "test"
		sut.scannedDCC = nil

		// When
		sut.userWishesToCreateACertificate()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
	}
	
	func test_userWishesToCreateACertificate_tokenNotNil_scannedDCCNotNil() {

		// Given
		sut.token = "test"
		sut.scannedDCC = "test"

		// When
		sut.userWishesToCreateACertificate()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
	}

	func test_userWishesToSeeScannedEvent() {

		// Given
		let remoteEvent = RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: nil,
				status: .complete
			),
			signedResponse: nil
		)

		// When
		sut.userWishesToSeeScannedEvent(remoteEvent)

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
	}

	func test_eventFlowDidCancel() {

		// Given
		sut.token = "test"
		sut.scannedDCC = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		navigationSpy.viewControllers = [
			PaperProofStartScanningViewController(viewModel: PaperProofStartScanningViewModel(coordinator: sut)),
			PaperProofInputCouplingCodeViewController(viewModel: PaperProofInputCouplingCodeViewModel(coordinator: sut)),
			PaperProofScanViewController(viewModel: PaperProofScanViewModel(coordinator: sut))
		]

		// When
		sut.eventFlowDidCancel()

		// Then
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
	}

	func test_eventFlowDidComplete() {

		// Given
		sut.token = "test"
		sut.scannedDCC = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))

		// When
		sut.eventFlowDidComplete()

		// Then
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
	}
	
	func test_eventFlowDidCompleteButVisitorPassNeedsCompletion() {
		
		// Given
		sut.token = "test"
		sut.scannedDCC = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCompleteButVisitorPassNeedsCompletion()
		
		// Then
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedDCC).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
	}
	
	func test_userWishesMoreInformationOnNoInputToken() throws {

		// Given

		// When
		sut.userWishesMoreInformationOnNoInputToken()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holderPaperproofNotokenTitle()
		expect(viewModel.content.body) == L.holderPaperproofNotokenMessage()
	}
	
	func test_userWishesMoreInformationOnWhichProofsCanBeUsed() {
		
		// Given
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
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.displayError(content: content, backAction: {})
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
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
