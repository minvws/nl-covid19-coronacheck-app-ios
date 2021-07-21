/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
import ViewControllerPresentationSpy
@testable import CTR

class PaperCertificateCheckViewControllerTests: XCTestCase {

	var sut: PaperCertificateCheckViewController!
	var coordinatorDelegateSpy: PaperCertificateCoordinatorDelegateSpy!
	var networkSpy: NetworkSpy!
	var cryptoSpy: CryptoManagerSpy!
	var couplingManagerSpy: CouplingManagerSpy!

	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = PaperCertificateCoordinatorDelegateSpy()
		networkSpy = NetworkSpy(configuration: .test)
		cryptoSpy = CryptoManagerSpy()
		couplingManagerSpy = CouplingManagerSpy(cryptoManager: cryptoSpy, networkManager: networkSpy)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_viewStateBlocked() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .blocked)), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderCheckdccBlockedTitle()
		expect(self.sut.sceneView.message) == L.holderCheckdccBlockedMessage()
		expect(self.sut.sceneView.primaryTitle) == L.holderCheckdccBlockedActionTitle()

		sut.assertImage()
	}

	func test_viewStateBlocked_primaryAction() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .blocked)), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWantsToGoBackToDashboard) == true
	}

	func test_viewStateExpired() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .expired)), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderCheckdccExpiredTitle()
		expect(self.sut.sceneView.message) == L.holderCheckdccExpiredMessage()
		expect(self.sut.sceneView.primaryTitle) == L.holderCheckdccExpiredActionTitle()

		sut.assertImage()
	}

	func test_viewStateExpired_primaryAction() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .expired)), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWantsToGoBackToDashboard) == true
	}

	func test_viewStateRejected() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .rejected)), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderCheckdccRejectedTitle()
		expect(self.sut.sceneView.message) == L.holderCheckdccRejectedMessage()
		expect(self.sut.sceneView.primaryTitle) == L.holderCheckdccRejectedActionTitle()

		sut.assertImage()
	}

	func test_viewStateRejected_primaryAction() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .rejected)), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWantsToGoBackToTokenEntry) == true
	}

	func test_alertServerBusy() {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.serverBusy), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)

		// When
		loadView()

		// Then
		alertVerifier.verify(
			title: L.generalNetworkwasbusyTitle(),
			message: L.generalNetworkwasbusyText(),
			animated: true,
			actions: [
				.default(L.generalNetworkwasbusyButton())
			],
			preferredStyle: .alert,
			presentingViewController: sut
		)
	}

	func test_alertServerBusy_okAction() throws {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.serverBusy), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		try alertVerifier.executeAction(forButton: L.generalNetworkwasbusyButton())

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWantsToGoBackToDashboard) == true
	}

	func test_alertNoInternet() {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.noInternetConnection), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)

		// When
		loadView()

		// Then
		alertVerifier.verify(
			title: L.generalErrorNointernetTitle(),
			message: L.generalErrorNointernetText(),
			animated: true,
			actions: [
				.default(L.holderVaccinationErrorAgain()),
				.cancel(L.generalClose())
			],
			preferredStyle: .alert,
			presentingViewController: sut
		)
	}

	func test_alertNoInternet_cancelAction() throws {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.noInternetConnection), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		try alertVerifier.executeAction(forButton: L.generalClose())

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWantsToGoBackToDashboard) == true
	}

	func test_alertNoInternet_okAction() throws {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.noInternetConnection), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		try alertVerifier.executeAction(forButton: L.holderVaccinationErrorAgain())

		// Then
		expect(self.couplingManagerSpy.invokedCheckCouplingStatusCount).toEventually(equal(2))
	}

	func test_alertTechnicalError() {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.invalidResponse), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)

		// When
		loadView()

		// Then
		alertVerifier.verify(
			title: L.generalErrorTitle(),
			message: L.generalErrorTechnicalCustom("110, check coupling code"),
			animated: true,
			actions: [
				.default(L.generalClose())
			],
			preferredStyle: .alert,
			presentingViewController: sut
		)
	}

	func test_alertTechnicalError_okAction() throws {

		// Given
		let alertVerifier = AlertVerifier()
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.invalidResponse), ())

		sut = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test",
				couplingManager: couplingManagerSpy
			)
		)
		loadView()

		// When
		try alertVerifier.executeAction(forButton: L.generalClose())

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWantsToGoBackToDashboard) == true
	}
}