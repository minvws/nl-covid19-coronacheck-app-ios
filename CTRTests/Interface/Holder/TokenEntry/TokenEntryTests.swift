/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length file_length

import Foundation
import XCTest
import Nimble
@testable import CTR
import SnapshotTesting

/// (Experimentally) combines TokenEntryViewModel tests and TokenEntryViewController snapshot tests
class TokenEntryViewModelTests: XCTestCase {

	private var holderCoordinatorSpy: HolderCoordinatorDelegateSpy!
	private var proofManagerSpy: ProofManagingSpy!
	private var networkManagerSpy: NetworkSpy!
	private var tokenValidatorSpy: TokenValidatorSpy!

	private var sut: TokenEntryViewModel!

	override func setUp() {
		super.setUp()

		holderCoordinatorSpy = HolderCoordinatorDelegateSpy()
		proofManagerSpy = ProofManagingSpy()
		networkManagerSpy = NetworkSpy()
		tokenValidatorSpy = TokenValidatorSpy()

//		isRecording = true
	}

	func test_withoutInitialRequestToken_initialState() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Assert
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryRegularflowRetryTitle()
		expect(self.sut.networkErrorAlert).to(beNil())
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.confirmResendVerificationAlertTitle) == L.holderTokenentryRegularflowConfirmresendverificationalertTitle()
		expect(self.sut.confirmResendVerificationAlertMessage) == L.holderTokenentryRegularflowConfirmresendverificationalertMessage()
		expect(self.sut.confirmResendVerificationAlertOkayButton) == L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()
		expect(self.sut.confirmResendVerificationAlertCancelButton) == L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_initialState() {
		// Arrange
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowNextButton) == false
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryRegularflowRetryTitle()
		expect(self.sut.networkErrorAlert).to(beNil())
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())
		expect(self.sut.confirmResendVerificationAlertTitle) == L.holderTokenentryUniversallinkflowConfirmresendverificationalertTitle()
		expect(self.sut.confirmResendVerificationAlertMessage) == L.holderTokenentryUniversallinkflowConfirmresendverificationalertMessage()
		expect(self.sut.confirmResendVerificationAlertOkayButton) == L.holderTokenentryUniversallinkflowConfirmresendverificationalertOkaybutton()
		expect(self.sut.confirmResendVerificationAlertCancelButton) == L.holderTokenentryUniversallinkflowConfirmresendverificationalertCancelbutton()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_makesNoCallToProofManager() {
		sut = mockedViewModel(withRequestToken: nil)
		expect(self.networkManagerSpy.invokedFetchTestProviders) == false
	}

	// MARK: - Handle Input
	// `func handleInput(_ tokenInput: String?, verificationInput: String?) `

	func test_withoutInitialRequestToken_handleInput_withNilTokenInput_disablesNextButton() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: nil, currentValueOfVerificationInput: nil)

		// Assert
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withInvalidToken_disablesNextButtonAndHidesVerification() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)
		let invalidToken = "HELLO"

		tokenValidatorSpy.stubbedValidateResult = false

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: invalidToken, currentValueOfVerificationInput: nil)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidToken

		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withValidToken_hidingVerification_enablesNextButtonAndHidesVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		let validToken = "XXX-YYYYYYYYYYYY-Z2"

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: validToken, currentValueOfVerificationInput: nil)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withEmptyTokenInput_withEmptyVerificationInput_disablesNextButton() {
		// Arrange
		let emptyVerificationInput = ""
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.userDidUpdateVerificationField(rawVerificationInput: emptyVerificationInput, currentValueOfTokenInput: "")

		// Assert
		expect(self.tokenValidatorSpy.invokedValidate) == false
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
		// Arrange
		let nonemptyVerificationInput = "1234"
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.userDidUpdateVerificationField(rawVerificationInput: nonemptyVerificationInput, currentValueOfTokenInput: "")

		// Assert
		expect(self.tokenValidatorSpy.invokedValidate) == false
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withInitialRequestTokenSet_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		let nonemptyVerificationInput = "1234"
		sut = mockedViewModel(withRequestToken: .fake)

		// Act
		sut.userDidUpdateVerificationField(rawVerificationInput: nonemptyVerificationInput, currentValueOfTokenInput: "")

		// Assertn
		expect(self.tokenValidatorSpy.invokedValidate) == false
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - Next Button Pressed
	// `func nextButtonPressed(_ tokenInput: String?, verificationInput: String?)`

	func test_withoutInitialRequestToken_nextButtonPressed_withNilTokenInput_doesNothing() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(nil, verificationInput: nil)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == false
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - nextButtonPressed withNonemptyVerificationInput

	func test_withoutInitialRequestToken_nextButtonPressed_withNonemptyVerificationInput_withNoPreviousRequestTokenSet_doesNothing() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - initWithInitialRequestTokenSet

	func test_initWithInitialRequestTokenSet_fetchesProviders() {
		// Arrange

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == false
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false
		expect(self.sut.networkErrorAlert).to(beNil())
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_serverBusy_stopsProgressAndShowsServerBusyDialog() {
		// Arrange
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		tokenValidatorSpy.stubbedValidateResult = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.title).toEventually(equal(L.generalNetworkwasbusyTitle()))
		expect(self.sut.message).toEventually(equal(L.generalNetworkwasbusyText()))
		expect(self.sut.primaryTitle).toEventually(equal(L.generalNetworkwasbusyButton()))
		expect(self.sut.shouldShowUserNeedsATokenButton).toEventually(beTrue())
		expect(self.sut.shouldEnableNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowVerificationEntryField).toEventually(beFalse())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_requestTimedOut_stopsProgressAndShowsErrorDialog() {
		// Arrange
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .requestTimedOut)), ())
		tokenValidatorSpy.stubbedValidateResult = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.networkErrorAlert).toNot(beNil())
		expect(self.sut.networkErrorAlert?.title) == L.holderErrorstateTitle()
		expect(self.sut.networkErrorAlert?.subTitle) == L.generalErrorServerUnreachable()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.shouldShowResendVerificationButton) == false
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_noInternet_stopsProgressAndShowsErrorDialog() {
		// Arrange
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		tokenValidatorSpy.stubbedValidateResult = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.networkErrorAlert).toNot(beNil())
		expect(self.sut.networkErrorAlert?.title) == L.generalErrorNointernetTitle()
		expect(self.sut.networkErrorAlert?.subTitle) == L.generalErrorNointernetText()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.shouldShowResendVerificationButton) == false
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_clientError_stopsProgressAndShowsErrorDialog() {
		// Arrange
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)), ())
		tokenValidatorSpy.stubbedValidateResult = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.message).toEventually(equal(L.holderErrorstateClientMessage("i 120 000 020")))
		expect(self.sut.primaryTitle).toEventually(equal(L.holderErrorstateOverviewAction()))
		expect(self.sut.shouldShowUserNeedsATokenButton).toEventually(beTrue())
		expect(self.sut.shouldEnableNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowVerificationEntryField).toEventually(beFalse())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_serverError_stopsProgressAndShowsErrorDialog() {
		// Arrange
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99780), error: .serverError)), ())
		tokenValidatorSpy.stubbedValidateResult = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.message).toEventually(equal(L.holderErrorstateServerMessage("i 120 000 500 99780")))
		expect(self.sut.primaryTitle).toEventually(equal(L.holderErrorstateOverviewAction()))
		expect(self.sut.shouldShowUserNeedsATokenButton).toEventually(beTrue())
		expect(self.sut.shouldEnableNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowVerificationEntryField).toEventually(beFalse())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchResult_networkFailure_stopsProgressAndShowsTechnicalErrorAlertAndShowsTokenEntryField() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.networkErrorAlert).toNot(beNil())
		expect(self.sut.networkErrorAlert?.title) == L.generalErrorTitle()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.shouldShowResendVerificationButton) == false
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withUnidentifiableTestProvider_showsErrorMessage() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([]), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_startsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == RequestToken.fake.token
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeComplete, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakePending, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_invalid_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeInvalid, SignedResponse(payload: "test", signature: "test"))), ())
		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_unknown_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeUnknown, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_failure_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.networkErrorAlert).toNot(beNil())
		expect(self.sut.networkErrorAlert?.title) == L.generalErrorTitle()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()
		expect(self.sut.shouldEnableNextButton) == false

		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: initWithInitialRequestTokenSet nextButtonPressed

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_fetchesProviders() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		networkManagerSpy.reset()

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowUserNeedsATokenButton) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.networkErrorAlert).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_success_stopsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()

		// Nevertheless, the progress should be stopped.
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_failure_stopsProgressAndShowsTechnicalErrorAlert() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.title).toEventually(equal(L.generalNetworkwasbusyTitle()))
		expect(self.sut.message).toEventually(equal(L.generalNetworkwasbusyText()))
		expect(self.sut.primaryTitle).toEventually(equal(L.generalNetworkwasbusyButton()))
		expect(self.sut.shouldShowUserNeedsATokenButton).toEventually(beTrue())
		expect(self.sut.shouldEnableNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowVerificationEntryField).toEventually(beFalse())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()
		networkManagerSpy.reset()

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
		// Arrange
		let validToken = RequestToken.fake.token
		let verificationInput = "1234"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == validToken
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code) == verificationInput
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeComplete, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeComplete, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsNotEmpty_showsErrorAndResetsUIForVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let validToken = RequestToken.fake.token
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut.nextButtonTapped(validToken, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeInvalid, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeUnknown, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryUniversallinkflowErrorInvalidCode()
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.networkErrorAlert).toNot(beNil())
		expect(self.sut.networkErrorAlert?.title) == L.generalErrorTitle()
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - nextButtonPressed withEmptyVerificationInput

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withInvalidTokenInput_setsErrorMessage() {
		// Arrange
		let invalidTokenInput = "🍔"
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(invalidTokenInput, verificationInput: "")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == false
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidTokenInput
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryRegularflowErrorInvalidCode()
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowUserNeedsATokenButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withLowercaseTokenInput_createsTokenWithUppercaseInput() {
		// Arrange
		let validLowercaseToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validLowercaseToken, verificationInput: "")

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validLowercaseToken.uppercased()
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withLowercaseTokenInput_withSpaces_createsTokenWithUppercaseInputWithoutSpaces() {
		// Arrange
		let validLowercaseToken = "x xx-yy  yyyyy   yyyyy-z 2   "
		tokenValidatorSpy.stubbedValidateResult = true

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validLowercaseToken, verificationInput: "")

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == "XXX-yyyyyyyyyyyy-z2".uppercased()
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_callsFetchProviders() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

//	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_success_stopsProgress() {
//		// Arrange
//		let validToken = "xxx-yyyyyyyyyyyy-z2"
//		tokenValidatorSpy.stubbedValidateResult = true
//		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
//		sut = mockedViewModel(withRequestToken: nil)
//
//		// Act
//		sut.nextButtonTapped(validToken, verificationInput: "")
//
//		// Assert
//		expect(self.sut.shouldShowProgress) == false
//		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
//		expect(self.sut.shouldEnableNextButton) == true
//		expect(self.sut.shouldShowNextButton) == true
//		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
//		expect(self.sut.message) == L.holderTokenentryRegularflowText()
//
//		TokenEntryViewController(viewModel: sut).assertImage()
//	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_failure_stopsProgressAndShowsTechnicalErrorAlert() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)), ())
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.networkManagerSpy.invokedFetchTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.message).toEventually(equal(L.holderErrorstateClientMessage("i 120 000 020")))
		expect(self.sut.primaryTitle).toEventually(equal(L.holderErrorstateOverviewAction()))
		expect(self.sut.shouldShowUserNeedsATokenButton).toEventually(beTrue())
		expect(self.sut.shouldEnableNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())
		expect(self.sut.shouldShowVerificationEntryField).toEventually(beFalse())
		expect(self.sut.shouldShowNextButton).toEventually(beTrue())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withUnidentifiableTestProvider_showsErrorMessage() {
		// Arrange
		let validToken = "zzz-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryRegularflowErrorInvalidCode()
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == "YYYYYYYYYYYY"
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeComplete, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakePending, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let validToken = "xxx-yyyyyyyyyyyy-z2"

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_clearTokenField_resetsUIForTokenEntry() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let validToken = "xxx-yyyyyyyyyyyy-z2"

		sut = mockedViewModel(withRequestToken: nil)
		sut.userDidUpdateTokenField(rawTokenInput: validToken, currentValueOfVerificationInput: "")

		sut.nextButtonTapped(validToken, verificationInput: "")
		expect(self.sut.shouldShowVerificationEntryField) == true

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "", currentValueOfVerificationInput: "")

		// Assert
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_changeTokenField_resetsUIForTokenEntry() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())
		let validToken = "xxx-yyyyyyyyyyyy-z2"

		sut = mockedViewModel(withRequestToken: nil)
		sut.userDidUpdateTokenField(rawTokenInput: validToken, currentValueOfVerificationInput: "")

		sut.nextButtonTapped(validToken, verificationInput: "")
		expect(self.sut.shouldShowVerificationEntryField) == true

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: String(validToken.dropLast()), currentValueOfVerificationInput: "")

		// Assert
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeInvalid, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryRegularflowErrorInvalidCode()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeUnknown, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderTokenentryRegularflowErrorInvalidCode()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.networkErrorAlert).toNot(beNil())
		expect(self.sut.networkErrorAlert?.title) == L.generalErrorTitle()
		expect(self.sut.shouldEnableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == L.holderTokenentryRegularflowTitle()
		expect(self.sut.message) == L.holderTokenentryRegularflowText()

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - Skipping the entry when no verification is needed:

	func test_withInitialRequestToken_whenNoVerificationIsRequired_shouldHideTheInputFields() {
		// Arrange
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeComplete, SignedResponse(payload: "test", signature: "test"))), ())
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false
		expect(self.sut.message).to(beNil())
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.networkErrorAlert).to(beNil())
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.message).to(beNil())
		expect(self.holderCoordinatorSpy.invokedUserWishesToMakeQRFromNegativeTest) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - resendVerificationCodeButtonTapped

	func test_withoutInitialRequestToken_withoutAnInitialFetch_resendVerificationCodeButtonTapped_shouldNotFetchProviders() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.resendVerificationCodeButtonTapped()

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResult) == false
		expect(self.sut.shouldShowProgress) == false

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_withAnInitialFetch_resendVerificationCodeButtonTapped_shouldFetchProviders() {
		// Arrange
		let validToken = "XXX-YYYYYYYYYYYY-Z2"

		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: nil)
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Act
		sut.resendVerificationCodeButtonTapped()
		// Assert
		// clear error message
		// should not present an error message  Strings.holderTokenEntryErrorInvalidCode
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == "YYYYYYYYYYYY"
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())
		expect(self.sut.fieldErrorMessage).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_resendVerificationCodeButtonTapped_shouldFetchProviders() {

		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		// Act
 		sut.resendVerificationCodeButtonTapped()

		// Assert

		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.shouldEnableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.message) == L.holderTokenentryUniversallinkflowText()
		expect(self.sut.resendVerificationButtonTitle) == L.holderTokenentryUniversallinkflowRetryTitle()
		expect(self.sut.networkErrorAlert).to(beNil())
		expect(self.sut.title) == L.holderTokenentryUniversallinkflowTitle()
		expect(self.sut.fieldErrorMessage).to(beNil())

		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token) == .fake
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - resendVerificationCodeButtonTapped

	func test_userHasNoTokenButtonTapped_shouldCallToDelegate() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.userHasNoTokenButtonTapped()

		// Assert
		expect(self.holderCoordinatorSpy.invokedPresentInformationPage) == true
	}

	// MARK: - Other

	func test_withoutInitialRequestToken_withAnInitialFetch_typedVerificationCode_clearTokenField_retypeToken_shouldIgnoreExistingVerificationCodeFieldValue() {
		// Arrange
		let validToken = "XXX-YYYYYYYYYYYY-Z2"

		tokenValidatorSpy.stubbedValidateResult = true
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(RemoteEvent(.fakeVerificationRequired, SignedResponse(payload: "test", signature: "test"))), ())

		sut = mockedViewModel(withRequestToken: nil)

		sut.userDidUpdateTokenField(rawTokenInput: validToken, currentValueOfVerificationInput: "")
		sut.nextButtonTapped(validToken, verificationInput: "")
		expect(self.sut.shouldShowVerificationEntryField) == true

		// Act
		// Clear the token field
		sut.userDidUpdateTokenField(rawTokenInput: "", currentValueOfVerificationInput: "")
		expect(self.sut.shouldShowVerificationEntryField) == false

		// Update the token field again:
		// Simulate having entered a value into verification code before it was hidden

		let nextValidToken = "TTTTTTTTTTTT"
		let currentValueOfVerificationInput = "1234"
		sut.userDidUpdateTokenField(rawTokenInput: "XXX-\(nextValidToken)-Z2", currentValueOfVerificationInput: currentValueOfVerificationInput)

		proofManagerSpy.reset()
		networkManagerSpy.reset()
		networkManagerSpy.stubbedFetchTestProvidersCompletionResult = (.success([.fake]), ())

		sut.nextButtonTapped("XXX-\(nextValidToken)-Z2", verificationInput: currentValueOfVerificationInput)

		// Assert

		// The VM should ignore the verification input because it should be still in `inputToken` mode
		// So it should submit to fetchTestResult with a nil Verification Code:
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == nextValidToken
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())
	}
	
	// MARK: - Sugar

	private func mockedViewModel(withRequestToken requestToken: RequestToken?) -> TokenEntryViewModel {
		return TokenEntryViewModel(
			coordinator: holderCoordinatorSpy,
			proofManager: proofManagerSpy,
			networkManager: networkManagerSpy,
			requestToken: requestToken,
			tokenValidator: tokenValidatorSpy
		)
	}
}

extension ProofManagingSpy {

	// NB: only resets the members used so far in this file..
	func reset() {
		invokedFetchTestResult = false
		invokedFetchTestResultCount = 0
		invokedFetchTestResultParameters = nil
		invokedFetchTestResultParametersList = []
		stubbedFetchTestResultOnCompletionResult = nil
	}
}

extension NetworkSpy {

	func reset() {

		invokedFetchTestProviders = false
		invokedFetchTestResult = false
		stubbedFetchTestProvidersCompletionResult = nil
		stubbedFetchTestResultCompletionResult = nil
	}
}
