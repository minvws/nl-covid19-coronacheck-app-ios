/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import SnapshotTesting
import ViewControllerPresentationSpy
import Nimble
@testable import CTR
@testable import Transport
@testable import Shared

class InputRetrievalCodeControllerTests: XCTestCase {

	private var sut: InputRetrievalCodeViewController!
	private var viewModel: InputRetrievalCodeViewModel!
	private var window: UIWindow!

	private var holderCoordinatorSpy: HolderCoordinatorDelegateSpy!
	private var tokenValidatorSpy: TokenValidatorSpy!
	private var networkManagerSpy: NetworkSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		// Ideally we'd be able to use a `TokenEntryViewModelSpy` but
		// currently not possible due to @Bindable not working in protocols.
		holderCoordinatorSpy = HolderCoordinatorDelegateSpy()
		networkManagerSpy = NetworkSpy()
		tokenValidatorSpy = TokenValidatorSpy()
		environmentSpies = setupEnvironmentSpies()

		window = UIWindow()
	}

	func test_withoutInitialRequestToken_tappingIHaveReceivedNoCode_showsAResendDialog() {

		let alertVerifier = AlertVerifier()
		// Arrange
		viewModel = mockedViewModel(withRequestToken: nil)
		sut = InputRetrievalCodeViewController(viewModel: viewModel)

		loadView(viewController: sut)

		// Act
		sut.displayResendVerificationConfirmationAlert()

		// Assert
		alertVerifier.verify(
			title: L.holderTokenentryRegularflowConfirmresendverificationalertTitle(),
			message: L.holderTokenentryRegularflowConfirmresendverificationalertMessage(),
			animated: true,
			actions: [
				.default(L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()),
				.cancel(L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton())
			],
			preferredStyle: .alert,
			presentingViewController: sut
		)
	}

	func test_withInitialRequestTokenSet_tappingIHaveReceivedNoCode_showsAResendDialog() {
		let alertVerifier = AlertVerifier()
		// Arrange
		viewModel = mockedViewModel(withRequestToken: .fake)
		sut = InputRetrievalCodeViewController(viewModel: viewModel)

		loadView(viewController: sut)

		// Act
		sut.displayResendVerificationConfirmationAlert()

		// Assert
		alertVerifier.verify(
			title: L.holderTokenentryRegularflowConfirmresendverificationalertTitle(),
			message: L.holderTokenentryRegularflowConfirmresendverificationalertMessage(),
			animated: true,
			actions: [
				.default(L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()),
				.cancel(L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton())
			],
			preferredStyle: .alert,
			presentingViewController: sut
		)
	}
	
	// MARK: - Sugar

	private func mockedViewModel(withRequestToken requestToken: RequestToken?) -> InputRetrievalCodeViewModel {
		return InputRetrievalCodeViewModel(
			coordinator: holderCoordinatorSpy,
			requestToken: requestToken,
			tokenValidator: tokenValidatorSpy
		)
	}

	private func loadView(viewController: UIViewController) {
		_ = viewController.view
		//		window.addSubview(view)
		//		RunLoop.current.run(until: Date())
	}
}
