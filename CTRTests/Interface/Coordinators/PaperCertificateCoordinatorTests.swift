/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class PaperCertificateCoordinatorTests: XCTestCase {

	var sut: PaperCertificateCoordinator!
	var cryptoSpy: CryptoManagerSpy!
	var flowSpy: PaperCertificateFlowDelegateSpy!
	var navigationSpy: NavigationControllerSpy!

	override func setUp() {

		super.setUp()
		cryptoSpy = CryptoManagerSpy()
		flowSpy = PaperCertificateFlowDelegateSpy()
		navigationSpy = NavigationControllerSpy()

		sut = PaperCertificateCoordinator(delegate: flowSpy, cryptoManager: cryptoSpy)
		sut.navigationController = navigationSpy
	}

	// MARK: - Tests

	func test_userWishesToEnterToken() {

		// Given

		// When
		sut.userWishesToEnterToken()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userDidSubmitPaperCertificateToken() {

		// Given

		// When
		sut.userDidSubmitPaperCertificateToken(token: "test")

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == false
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
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userWishesToScanCertificate() {

		// Given

		// When
		sut.userWishesToScanCertificate()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == false
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
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == false
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
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == false
		expect(self.sut.token) == "test"
		expect(self.sut.scannedQR) == "test"
	}

	func test_userWantsToGoBackToTokenEntry() {

		// Given
		navigationSpy.viewControllers = [
			PaperCertificateStartViewController(viewModel: PaperCertificateStartViewModel(coordinator: sut)),
			PaperCertificateTokenEntryViewController(viewModel: PaperCertificateTokenEntryViewModel(coordinator: sut)),
			PaperCertificateScanViewController(viewModel: PaperCertificateScanViewModel(coordinator: sut, cryptoManager: cryptoSpy))
		]
		sut.scannedQR = "test"
		sut.token = "test"

		// When
		sut.userWantsToGoBackToTokenEntry()

		// Then
		expect(self.navigationSpy.popToViewControllerCalled) == true
		expect(self.navigationSpy.viewControllers).to(haveCount(2))
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.token) == "test"
	}

	func test_userWantsToGoBackToTokenEntry_notInStack() {

		// Given
		navigationSpy.viewControllers = [
			PaperCertificateStartViewController(viewModel: PaperCertificateStartViewModel(coordinator: sut))
		]

		// When
		sut.userWantsToGoBackToTokenEntry()

		// Then
		expect(self.navigationSpy.popToViewControllerCalled) == false
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.sut.scannedQR).to(beNil())
	}

	func test_userWishesToSeeScannedEvent() {

//		// Given
//		let remoteEvent = RemoteEvent(
//			wrapper: EventFlow.EventResultWrapper(
//				providerIdentifier: "CC",
//				protocolVersion: "3.0",
//				identity: nil,
//				status: .complete,
//				result: nil
//			),
//			signedResponse: nil
//		)
//
//		// When
//		sut.userWishesToSeeScannedEvent(remoteEvent)
//
//		// Then
//		expect(self.navigationSpy.pushViewControllerCallCount) == 1
	}

	func test_eventFlowDidCancel() {

		// Given
		sut.token = "test"
		sut.scannedQR = "test"
		sut.childCoordinators.append(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		navigationSpy.viewControllers = [
			PaperCertificateStartViewController(viewModel: PaperCertificateStartViewModel(coordinator: sut)),
			PaperCertificateTokenEntryViewController(viewModel: PaperCertificateTokenEntryViewModel(coordinator: sut)),
			PaperCertificateScanViewController(viewModel: PaperCertificateScanViewModel(coordinator: sut, cryptoManager: cryptoSpy))
		]

		// When
		sut.eventFlowDidCancel()

		// Then
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == false
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
		expect(self.navigationSpy.popToViewControllerCalled) == true
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
		expect(self.flowSpy.invokedAddCertificateFlowDidFinish) == true
		expect(self.sut.token).to(beNil())
		expect(self.sut.scannedQR).to(beNil())
		expect(self.sut.childCoordinators).to((haveCount(0)))
	}
}

class PaperCertificateFlowDelegateSpy: PaperCertificateFlowDelegate {

	var invokedAddCertificateFlowDidFinish = false
	var invokedAddCertificateFlowDidFinishCount = 0

	func addCertificateFlowDidFinish() {
		invokedAddCertificateFlowDidFinish = true
		invokedAddCertificateFlowDidFinishCount += 1
	}
}
