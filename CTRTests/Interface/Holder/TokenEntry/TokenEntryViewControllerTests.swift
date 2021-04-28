//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import SnapshotTesting
import Nimble
@testable import CTR

class TokenEntryViewControllerTests: XCTestCase {

	private var sut: TokenEntryViewController!
	private var viewModel: TokenEntryViewModel!

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
	}

	func test_withoutInitialRequestToken_tappingIHaveReceivedNoCode_showsAResendDialog() {

		// Arrange
		var presentedAlertController: UIAlertController?

		viewModel = mockedViewModel(withRequestToken: nil)
		sut = TokenEntryViewController(viewModel: viewModel, alertPresenter: { presentedAlertController = $0 })

		// Act
		sut.displayResendVerificationConfirmationAlert()

		// Assert
		expect(presentedAlertController?.title) == .holderTokenEntryRegularFlowConfirmResendVerificationAlertTitle
		expect(presentedAlertController?.message) == .holderTokenEntryRegularFlowConfirmResendVerificationAlertMessage
		expect(presentedAlertController?.actions.count) == 2

		// Order is also important
		let okayAction = presentedAlertController?.actions[0]
		let cancelAction = presentedAlertController?.actions[1]

		expect(okayAction?.title) == .holderTokenEntryRegularFlowConfirmResendVerificationAlertOkayButton
		expect(cancelAction?.title) == .holderTokenEntryRegularFlowConfirmResendVerificationCancelButton
	}

	func test_withInitialRequestTokenSet_tappingIHaveReceivedNoCode_showsAResendDialog() {

		// Arrange
		var presentedAlertController: UIAlertController?

		viewModel = mockedViewModel(withRequestToken: .fake)
		sut = TokenEntryViewController(viewModel: viewModel, alertPresenter: { presentedAlertController = $0 })

		// Act
		sut.displayResendVerificationConfirmationAlert()

		// Assert
		expect(presentedAlertController?.title) == .holderTokenEntryUniversalLinkFlowConfirmResendVerificationAlertTitle
		expect(presentedAlertController?.message) == .holderTokenEntryUniversalLinkFlowConfirmResendVerificationAlertMessage
		expect(presentedAlertController?.actions.count) == 2

		// Order is also important
		let okayAction = presentedAlertController?.actions[0]
		let cancelAction = presentedAlertController?.actions[1]

		expect(okayAction?.title) == .holderTokenEntryUniversalLinkFlowConfirmResendVerificationAlertOkayButton
		expect(cancelAction?.title) == .holderTokenEntryUniversalLinkFlowConfirmResendVerificationCancelButton
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
}
