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
@testable import Transport
@testable import Shared

class PaperProofCheckViewControllerTests: XCTestCase {

	var sut: PaperProofCheckViewController!
	var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_viewStateBlocked() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .blocked)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
			)
		)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderCheckdccBlockedTitle()
		expect(self.sut.sceneView.message) == L.holderCheckdccBlockedMessage()
		expect(self.sut.sceneView.primaryTitle) == L.general_toMyOverview()

		sut.assertImage()
	}

	func test_viewStateBlocked_primaryAction() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .blocked)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
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
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .rejected)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
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
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .rejected)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
			)
		)
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedDismiss) == true
	}

	func test_alertNoInternet() {

		// Given
		let alertVerifier = AlertVerifier()
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
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
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
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
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		sut = PaperProofCheckViewController(
			viewModel: PaperProofCheckViewModel(
				coordinator: coordinatorDelegateSpy,
				scannedDcc: "test",
				couplingCode: "test"
			)
		)
		loadView()

		// When
		try alertVerifier.executeAction(forButton: L.holderVaccinationErrorAgain())

		// Then
		expect(self.environmentSpies.couplingManagerSpy.invokedCheckCouplingStatusCount).toEventually(equal(2))
	}
}
