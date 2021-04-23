//
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

    func test_initialState_withoutRequestToken() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)

        // Assert
        expect(self.sut.shouldShowProgress) == false
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.resendVerificationButtonTitle).to(beNil())
        expect(self.sut.resendVerificationButtonEnabled) == false
        expect(self.sut.showTechnicalErrorAlert) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_initialState_withRequestToken() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)

        // Assert
        expect(self.sut.shouldShowProgress) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == false
        expect(self.sut.shouldShowNextButton) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.resendVerificationButtonTitle).to(beNil())
        expect(self.sut.resendVerificationButtonEnabled) == false
        expect(self.sut.showTechnicalErrorAlert) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_withoutInitialRequestToken_makesNoCallToProofManager() {
        sut = mockedViewModel(withRequestToken: nil)
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
    }

    // MARK: - Handle Input
    // `func handleInput(_ tokenInput: String?, verificationInput: String?) `

    func test_handleInput_withNilTokenInput_disablesNextButton() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.handleInput(nil, verificationInput: nil)

        // Assert
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.fieldErrorMessage).to(beNil())

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withInvalidToken_disablesNextButtonAndHidesVerification() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let invalidToken = "Hello"

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

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withValidToken_hidingVerification_enablesNextButtonAndHidesVerification() {
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

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withEmptyTokenInput_withEmptyVerificationInput_disablesNextButton() {
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

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
        // Arrange
        let nonemptyVerificationInput = "1234"
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.handleInput("", verificationInput: nonemptyVerificationInput)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidate) == false
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.fieldErrorMessage).to(beNil())

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    // MARK: - Next Button Pressed
    // `func nextButtonPressed(_ tokenInput: String?, verificationInput: String?)`

    func test_nextButtonPressed_withNilTokenInput_doesNothing() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(nil, verificationInput: nil)

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    // MARK: - nextButtonPressed withNonemptyVerificationInput

    func test_nextButtonPressed_withNonemptyVerificationInput_withNoPreviousRequestTokenSet_doesNothing() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(nil, verificationInput: "1234")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_fetchesProviders() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(nil, verificationInput: "1234")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.shouldShowProgress) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        expect(self.sut.showTechnicalErrorAlert) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_success_stopsProgress() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        let validToken = RequestToken.fake.token

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.shouldShowProgress) == false
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_failure_stopsProgressAndShowsError() {
        // Arrange
        proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())
        tokenValidatorSpy.stubbedValidateResult = true
        let validToken = RequestToken.fake.token

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.proofManagerSpy.invokedGetTestProvider) == false

        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.shouldShowProgress) == false
        expect(self.sut.showTechnicalErrorAlert) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withUnidentifiableTestProvider_showsErrorMessage() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        let validToken = RequestToken.fake.token

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.shouldShowProgress) == false
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_startsProgress() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        let validToken = RequestToken.fake.token

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.shouldShowProgress) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
        // Arrange
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == validToken
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code) == verificationInput
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_verificationRequired_codeIsNotEmpty_showsErrorAndResetsUIForVerification() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.resendVerificationButtonEnabled) == false
        expect(self.sut.resendVerificationButtonTitle) == String(format: .holderTokenEntryRetryCountdown, "\(10)")
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_invalid_showsError() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_unknown_showsError() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_failure_showsError() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        sut = mockedViewModel(withRequestToken: .fake)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
        expect(self.sut.showTechnicalErrorAlert) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == .holderTokenEntryTitle
        expect(self.sut.message) == .holderTokenEntryText
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    // MARK: - nextButtonPressed withEmptyVerificationInput

    func test_nextButtonPressed_withEmptyVerificationInput_withInvalidTokenInput_setsErrorMessage() {
        // Arrange
        let invalidTokenInput = "🍔"
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(invalidTokenInput, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidTokenInput
        expect(self.sut.fieldErrorMessage) == String.holderTokenEntryErrorInvalidCode
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withLowercaseTokenInput_createsTokenWithUppercaseInput() {
        // Arrange
        let validLowercaseToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validLowercaseToken, verificationInput: "")

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validLowercaseToken.uppercased()
        expect(self.sut.shouldShowProgress) == true
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_callsFetchProviders() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_success_stopsProgress() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.shouldShowProgress) == false
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_failure_stopsProgressAndShowsError() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.shouldShowProgress) == false
        expect(self.sut.showTechnicalErrorAlert) == true

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        expect(self.proofManagerSpy.invokedGetTestProvider) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withUnidentifiableTestProvider_showsErrorMessage() {
        // Arrange
        let validToken = "zzz-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.shouldShowProgress) == false
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.fieldErrorMessage).to(beNil())
        expect(self.sut.shouldShowProgress) == true

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == "YYYYYYYYYYYY"
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
        // Arrange
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())
        let validToken = "xxx-yyyyyyyyyyyy-z2"

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.resendVerificationButtonEnabled) == false
        expect(self.sut.resendVerificationButtonTitle) == String(format: .holderTokenEntryRetryCountdown, "\(10)")
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.fieldErrorMessage) == "Unhandled: unknown"
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.fieldErrorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
        // Arrange
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

        sut = mockedViewModel(withRequestToken: nil)

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.fieldErrorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
        expect(self.sut.showTechnicalErrorAlert) == true
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withValidToken_showingVerification_enablesNextButtonAndShowsVerification() {

        // Arrange
        let validToken = "XXX-YYYYYYYYYYYY-Z2"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

        sut = mockedViewModel(withRequestToken: nil)

        sut.nextButtonPressed(validToken, verificationInput: "") // setup sut so that shouldShowVerificationEntryField == true

        // Act
        sut.handleInput(validToken, verificationInput: nil)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.fieldErrorMessage).to(beNil())

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
        expect(self.sut.resendVerificationButtonTitle).to(beNil())
        expect(self.sut.resendVerificationButtonEnabled) == false
        expect(self.sut.showTechnicalErrorAlert) == false

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
