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
	private var tokenValidatorSpy: TokenValidatorSpy!

	private var sut: TokenEntryViewModel!

	override func setUp() {
		super.setUp()

		holderCoordinatorSpy = HolderCoordinatorDelegateSpy()
		proofManagerSpy = ProofManagingSpy()
		tokenValidatorSpy = TokenValidatorSpy()
	}

	func test_withoutInitialRequestToken_initialState() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Assert
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.enableNextButton) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonTitle) == .holderTokenEntryRegularFlowRetryTitle
		expect(self.sut.resendVerificationButtonEnabled) == true
		expect(self.sut.showTechnicalErrorAlert) == false
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

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
		expect(self.sut.enableNextButton) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonTitle) == .holderTokenEntryRegularFlowRetryTitle
		expect(self.sut.resendVerificationButtonEnabled) == true
		expect(self.sut.showTechnicalErrorAlert) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_makesNoCallToProofManager() {
		sut = mockedViewModel(withRequestToken: nil)
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
	}

	// MARK: - Handle Input
	// `func handleInput(_ tokenInput: String?, verificationInput: String?) `

	func test_withoutInitialRequestToken_handleInput_withNilTokenInput_disablesNextButton() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.handleInput(nil, verificationInput: nil)

		// Assert
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withInvalidToken_disablesNextButtonAndHidesVerification() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)
		let invalidToken = "HELLO"

		tokenValidatorSpy.stubbedValidateResult = false

		// Act
		sut.handleInput(invalidToken, verificationInput: nil)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidToken

		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withValidToken_hidingVerification_enablesNextButtonAndHidesVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		let validToken = "XXX-YYYYYYYYYYYY-Z2"

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.handleInput(validToken, verificationInput: nil)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withEmptyTokenInput_withEmptyVerificationInput_disablesNextButton() {
		// Arrange
		let emptyVerificationInput = ""
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.handleInput("", verificationInput: emptyVerificationInput)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidate) == false
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
		// Arrange
		let nonemptyVerificationInput = "1234"
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.handleInput("", verificationInput: nonemptyVerificationInput)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidate) == false
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withInitialRequestTokenSet_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		let nonemptyVerificationInput = "1234"
		sut = mockedViewModel(withRequestToken: .fake)

		// Act
		sut.handleInput("", verificationInput: nonemptyVerificationInput)

		// Assertn
		expect(self.tokenValidatorSpy.invokedValidate) == false
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText

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
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - nextButtonPressed withNonemptyVerificationInput

	func test_withoutInitialRequestToken_nextButtonPressed_withNonemptyVerificationInput_withNoPreviousRequestTokenSet_doesNothing() {
		// Arrange
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - initWithInitialRequestTokenSet

	func test_initWithInitialRequestTokenSet_fetchesProviders() {
		// Arrange

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false
		expect(self.sut.showTechnicalErrorAlert) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_success_stopsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.shouldShowProgress) == false
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_failure_stopsProgressAndShowsTechnicalErrorAlert() {
		// Arrange
		proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())
		tokenValidatorSpy.stubbedValidateResult = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.proofManagerSpy.invokedGetTestProvider) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.showTechnicalErrorAlert) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// HERE
	func test_initWithInitialRequestTokenSet_fetchesProviders_withUnidentifiableTestProvider_showsErrorMessage() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_startsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == RequestToken.fake.token
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonEnabled) == true
		expect(self.sut.resendVerificationButtonTitle) == .holderTokenEntryUniversalLinkFlowRetryTitle
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_invalid_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_success_unknown_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_fetchesProviders_withIdentifiableTestProvider_failure_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.showTechnicalErrorAlert) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: initWithInitialRequestTokenSet nextButtonPressed

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_fetchesProviders() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.showTechnicalErrorAlert) == false

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_success_stopsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true

		// Expect an error to be shown (in tests only), as we haven't stubbed `proofManager?.getTestProvider()`
		expect(self.proofManagerSpy.invokedGetTestProvider) == true
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode

		// Nevertheless, the progress should be stopped.
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_failure_stopsProgressAndShowsTechnicalErrorAlert() {
		// Arrange
		proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())
		tokenValidatorSpy.stubbedValidateResult = true

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()
		proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.proofManagerSpy.invokedGetTestProvider) == false
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.showTechnicalErrorAlert) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withUnidentifiableTestProvider_showsErrorMessage() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		sut = mockedViewModel(withRequestToken: .fake)

		// Reset spies after init, (which does it's own `fetchProvider` pass):
		proofManagerSpy.reset()

		// Act
		sut.nextButtonTapped(nil, verificationInput: "1234")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
		// Arrange
		let validToken = RequestToken.fake.token
		let verificationInput = "1234"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == validToken
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code) == verificationInput
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsNotEmpty_showsErrorAndResetsUIForVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())
		let validToken = RequestToken.fake.token
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		// Act
		sut.nextButtonTapped(validToken, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.resendVerificationButtonEnabled) == true
		expect(self.sut.resendVerificationButtonTitle) == .holderTokenEntryUniversalLinkFlowRetryTitle
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryUniversalLinkFlowErrorInvalidCode
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_initWithInitialRequestTokenSet_validationRequired_nextButtonPressed_withNonemptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())
		let verificationInput = "1234"

		sut = mockedViewModel(withRequestToken: .fake)

		proofManagerSpy.reset()
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		// Act
		sut.nextButtonTapped(nil, verificationInput: verificationInput)

		// Assert
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.showTechnicalErrorAlert) == true
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message) == .holderTokenEntryUniversalLinkFlowText
		expect(self.sut.enableNextButton) == true
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
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidTokenInput
		expect(self.sut.fieldErrorMessage) == String.holderTokenEntryRegularFlowErrorInvalidCode
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

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
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

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
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

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
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_success_stopsProgress() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.shouldShowProgress) == false
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_failure_stopsProgressAndShowsTechnicalErrorAlert() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.showTechnicalErrorAlert) == true
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.proofManagerSpy.invokedGetTestProvider) == false
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withUnidentifiableTestProvider_showsErrorMessage() {
		// Arrange
		let validToken = "zzz-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryRegularFlowErrorInvalidCode
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.shouldShowProgress) == true
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == "YYYYYYYYYYYY"
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())
		expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
		// Arrange
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())
		let validToken = "xxx-yyyyyyyyyyyy-z2"

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.resendVerificationButtonEnabled) == true
		expect(self.sut.resendVerificationButtonTitle) == .holderTokenEntryUniversalLinkFlowRetryTitle
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryRegularFlowErrorInvalidCode
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == .holderTokenEntryRegularFlowErrorInvalidCode
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
		// Arrange
		let validToken = "xxx-yyyyyyyyyyyy-z2"
		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

		sut = mockedViewModel(withRequestToken: nil)

		// Act
		sut.nextButtonTapped(validToken, verificationInput: "")

		// Assert
		expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
		expect(self.sut.showTechnicalErrorAlert) == true
		expect(self.sut.enableNextButton) == true
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_withoutInitialRequestToken_handleInput_withValidToken_showingVerification_showsVerification() {

		// Arrange
		let validToken = "XXX-YYYYYYYYYYYY-Z2"

		tokenValidatorSpy.stubbedValidateResult = true
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

		sut = mockedViewModel(withRequestToken: nil)

		sut.nextButtonTapped(validToken, verificationInput: "") // setup sut so that shouldShowVerificationEntryField == true

		// Act
		sut.handleInput(validToken, verificationInput: nil)

		// Assert
		expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == true
		expect(self.sut.shouldShowTokenEntryField) == true
		expect(self.sut.shouldShowVerificationEntryField) == true
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.title) == .holderTokenEntryRegularFlowTitle
		expect(self.sut.message) == .holderTokenEntryRegularFlowText

		TokenEntryViewController(viewModel: sut).assertImage()
	}

	// MARK: - Skipping the entry when no verification is needed:

	func test_withInitialRequestToken_whenNoVerificationIsRequired_shouldHideTheInputFields() {
		// Arrange
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())
		proofManagerSpy.stubbedGetTestProviderResult = .fake
		proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())
		proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

		// Act
		sut = mockedViewModel(withRequestToken: .fake)

		// Assert
		expect(self.sut.shouldShowProgress) == false
		expect(self.sut.shouldShowTokenEntryField) == false
		expect(self.sut.shouldShowVerificationEntryField) == false
		expect(self.sut.enableNextButton) == false
		expect(self.sut.shouldShowNextButton) == false
		expect(self.sut.message).to(beNil())
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.resendVerificationButtonEnabled) == true
		expect(self.sut.resendVerificationButtonTitle) == .holderTokenEntryUniversalLinkFlowRetryTitle
		expect(self.sut.showTechnicalErrorAlert) == false
		expect(self.sut.title) == .holderTokenEntryUniversalLinkFlowTitle
		expect(self.sut.message).to(beNil())
		expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true

		TokenEntryViewController(viewModel: sut).assertImage()
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

extension ProofManagingSpy {

	// NB: only resets the members used so far in this file..
	func reset() {
		invokedFetchCoronaTestProviders = false
		invokedFetchCoronaTestProvidersCount = 0
		shouldInvokeFetchCoronaTestProvidersOnCompletion = false
		stubbedFetchCoronaTestProvidersOnErrorResult = nil

		invokedFetchTestResult = false
		invokedFetchTestResultCount = 0
		invokedFetchTestResultParameters = nil
		invokedFetchTestResultParametersList = []
		stubbedFetchTestResultOnCompletionResult = nil

		invokedFetchSignedTestResult = false
		invokedFetchSignedTestResultCount = 0
		stubbedFetchSignedTestResultOnCompletionResult = nil
		stubbedFetchSignedTestResultOnErrorResult = nil

		invokedGetTestProvider = false
		invokedGetTestProviderCount = 0
		invokedGetTestProviderParameters = nil
		invokedGetTestProviderParametersList = []
		stubbedGetTestProviderResult = nil // we don't want to do this, except check that progress started.
	}
}
