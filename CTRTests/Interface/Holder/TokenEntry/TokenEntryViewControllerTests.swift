//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import SnapshotTesting
import ViewControllerPresentationSpy
import Nimble
@testable import CTR

class TokenEntryViewControllerTests: XCTestCase {

	private var sut: TokenEntryViewController!
	private var viewModel: TokenEntryViewModel!
	private var window: UIWindow!

	private var holderCoordinatorSpy: HolderCoordinatorDelegateSpy!
	private var proofManagerSpy: ProofManagingSpy!
	private var tokenValidatorSpy: TokenValidatorSpy!

	override func setUp() {
		super.setUp()

		// Ideally we'd be able to use a `TokenEntryViewModelSpy` but
		// currently not possible due to @Bindable not working in protocols.
		holderCoordinatorSpy = HolderCoordinatorDelegateSpy()
		proofManagerSpy = ProofManagingSpy()
		tokenValidatorSpy = TokenValidatorSpy()

		window = UIWindow()
	}

	func test_withoutInitialRequestToken_tappingIHaveReceivedNoCode_showsAResendDialog() {

		let alertVerifier = AlertVerifier()
		// Arrange
		viewModel = mockedViewModel(withRequestToken: nil)
		sut = TokenEntryViewController(viewModel: viewModel)

		loadView(viewController: sut)

		// Act
		sut.displayResendVerificationConfirmationAlert()

		// Assert
		alertVerifier.verify(
			title: .holderTokenEntryRegularFlowConfirmResendVerificationAlertTitle,
			message: .holderTokenEntryRegularFlowConfirmResendVerificationAlertMessage,
			animated: true,
			actions: [
				.default(.holderTokenEntryRegularFlowConfirmResendVerificationAlertOkayButton),
				.cancel(.holderTokenEntryRegularFlowConfirmResendVerificationCancelButton)
			],
			preferredStyle: .actionSheet,
			presentingViewController: sut
		)
	}

	func test_withInitialRequestTokenSet_tappingIHaveReceivedNoCode_showsAResendDialog() {
		let alertVerifier = AlertVerifier()
		// Arrange
		viewModel = mockedViewModel(withRequestToken: .fake)
		sut = TokenEntryViewController(viewModel: viewModel)

		loadView(viewController: sut)

		// Act
		sut.displayResendVerificationConfirmationAlert()

		// Assert
		alertVerifier.verify(
			title: .holderTokenEntryRegularFlowConfirmResendVerificationAlertTitle,
			message: .holderTokenEntryRegularFlowConfirmResendVerificationAlertMessage,
			animated: true,
			actions: [
				.default(.holderTokenEntryRegularFlowConfirmResendVerificationAlertOkayButton),
				.cancel(.holderTokenEntryRegularFlowConfirmResendVerificationCancelButton)
			],
			preferredStyle: .actionSheet,
			presentingViewController: sut
		)
	}
	
	// MARK: - Sugar

	private func mockedViewModel(withRequestToken requestToken: RequestToken?) -> TokenEntryViewModel {
		return TokenEntryViewModel(
			coordinator: holderCoordinatorSpy,
			proofManager: proofManagerSpy,
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
