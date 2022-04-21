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
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userDidSubmitPaperProofToken() {

		// Given

		// When
		sut.userDidSubmitPaperProofToken(token: "test")

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token) == "test"
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userWantsToGoBackToDashboard() {

		// Given
		sut.token = "test"
		sut.scannedQR = "test"

		// When
		sut.userWantsToGoBackToDashboard()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userWishesToScanCertificate() {

		// Given

		// When
		sut.userWishesToScanCertificate()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userWishesToCreateACertificate_tokenNil() {

		// Given
		sut.token = nil

		// When
		sut.userWishesToCreateACertificate(message: "test")

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR) == "test"
	}

	func test_userWishesToCreateACertificate_TokenNotNil() {

		// Given
		sut.token = "test"

		// When
		sut.userWishesToCreateACertificate(message: "test")

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == false
		expect(self.sut.token) == "test"
		expect(self.sut.scannedQR) == "test"
	}

	func test_userWantsToGoBackToTokenEntry() {

		// Given
		navigationSpy.viewControllers = [
			PaperProofStartScanningViewController(viewModel: PaperProofStartScanningViewModel(coordinator: sut)),
			PaperProofInputCouplingCodeViewController(viewModel: PaperProofInputCouplingCodeViewModel(coordinator: sut)),
			PaperProofScanViewController(viewModel: PaperProofScanViewModel(coordinator: sut))
		]
		sut.scannedQR = "test"
		sut.token = "test"

		// When
		sut.userWantsToGoBackToTokenEntry()

		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers).to(haveCount(2))
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.token) == "test"
	}

	func test_userWantsToGoBackToTokenEntry_notInStack() {

		// Given
		navigationSpy.viewControllers = [
			PaperProofStartScanningViewController(viewModel: PaperProofStartScanningViewModel(coordinator: sut))
		]

		// When
		sut.userWantsToGoBackToTokenEntry()

		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userWishesToSeeScannedEvent() {

		// Given
		let remoteEvent = RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: nil,
				status: .complete,
				result: nil
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
		sut.scannedQR = "test"
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
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
	}

	func test_eventFlowDidComplete() {

		// Given
		sut.token = "test"
		sut.scannedQR = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))

		// When
		sut.eventFlowDidComplete()

		// Then
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
	}
	
	func test_eventFlowDidCompleteButVisitorPassNeedsCompletion() {
		
		// Given
		sut.token = "test"
		sut.scannedQR = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCompleteButVisitorPassNeedsCompletion()
		
		// Then
		expect(self.flowSpy.invokedAddPaperProofFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
	}

	
	func test_userWishesMoreInformationOnNoInputToken() throws {
		
		// Given
		
		// When
		sut.userWishesMoreInformationOnNoInputToken()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is PaperProofContentViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? PaperProofContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holderPaperproofNotokenTitle()
		expect(viewModel.content.body) == L.holderPaperproofNotokenMessage()
	}
	
	func test_userWishesMoreInformationOnInternationalQROnly() {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInformationOnInternationalQROnly()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel: ContentViewModel? = ((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel
		
		expect(viewModel?.content.title) == L.holderPaperproofInternationalQROnlyTitle()
		expect(viewModel?.content.body) == L.holderPaperproofInternationalQROnlyMessage()
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
		expect(self.navigationSpy.viewControllers.last is ErrorStateViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? ErrorStateViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_userWishesToGoBackToScanCertificate() {
		
		// Given
		navigationSpy.viewControllers = [
			PaperProofStartScanningViewController(viewModel: PaperProofStartScanningViewModel(coordinator: sut)),
			PaperProofScanViewController(viewModel: PaperProofScanViewModel(coordinator: sut)),
			PaperProofInputCouplingCodeViewController(viewModel: PaperProofInputCouplingCodeViewModel(coordinator: sut))
		]
		
		// When
		sut.userWishesToGoBackToScanCertificate()
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers).to(haveCount(2))
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
