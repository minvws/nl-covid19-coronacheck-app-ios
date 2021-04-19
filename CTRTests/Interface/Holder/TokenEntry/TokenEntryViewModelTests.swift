//
/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */
// swiftlint:disable type_body_length

import Foundation
import XCTest
import Nimble
@testable import CTR

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
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)

        // Assert
        expect(self.sut.token).to(beNil())
        expect(self.sut.showProgress) == false
        expect(self.sut.showVerification) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.secondaryButtonTitle).to(beNil())
        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.showError) == false
    }

    func test_initialState_withRequestToken() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)

        // Assert
        expect(self.sut.token) == "XXX-BBBBBBBBBBBB"
        expect(self.sut.showProgress) == true
        expect(self.sut.showVerification) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.secondaryButtonTitle).to(beNil())
        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.showError) == false
    }

    func test_withoutInitialRequestToken_makesNoCallToProofManager() {
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
    }

    // MARK: - Handle Input
    // `func handleInput(_ tokenInput: String?, verificationInput: String?) `

    func test_handleInput_withNilTokenInput_disablesNextButton() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)

        // Act
        sut.handleInput(nil, verificationInput: nil)

        // Assert
        expect(self.sut.enableNextButton) == false
        expect(self.sut.errorMessage).to(beNil())
    }

    func test_handleInput_withInvalidToken_disablesNextButtonAndHidesVerification() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let invalidToken = "Hello"

        tokenValidatorSpy.stubbedValidateResult = false

        // Act
        sut.handleInput(invalidToken, verificationInput: nil)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidToken

        expect(self.sut.enableNextButton) == false
        expect(self.sut.showVerification) == false
        expect(self.sut.errorMessage).to(beNil())
    }

    func test_handleInput_withValidToken_hidingVerification_enablesNextButtonAndHidesVerification() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "XXX-YYYYYYYYYYYY-Z2"

        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        sut.handleInput(validToken, verificationInput: nil)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken

        expect(self.sut.enableNextButton) == true
        expect(self.sut.showVerification) == false
        expect(self.sut.errorMessage).to(beNil())
    }

    func test_handleInput_withEmptyTokenInput_withEmptyVerificationInput_disablesNextButton() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let emptyVerificationInput = ""

        // Act
        sut.handleInput("", verificationInput: emptyVerificationInput)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidate) == false

        expect(self.sut.enableNextButton) == false

        expect(self.sut.errorMessage).to(beNil())
    }

    func test_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let nonemptyVerificationInput = "1234"

        // Act
        sut.handleInput("", verificationInput: nonemptyVerificationInput)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidate) == false

        expect(self.sut.enableNextButton) == true

        expect(self.sut.errorMessage).to(beNil())
    }

    // MARK: - Next Button Pressed
    // `func nextButtonPressed(_ tokenInput: String?, verificationInput: String?)`

    func test_nextButtonPressed_withNilTokenInput_doesNothing() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)

        // Act
        sut.nextButtonPressed(nil, verificationInput: nil)

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
    }

    // MARK: - nextButtonPressed withNonemptyVerificationInput

    func test_nextButtonPressed_withNonemptyVerificationInput_withNoPreviousRequestTokenSet_doesNothing() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)

        // Act
        sut.nextButtonPressed(nil, verificationInput: "1234")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
        expect(self.sut.errorMessage).to(beNil())
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_fetchesProviders() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)

        // Act
        sut.nextButtonPressed(nil, verificationInput: "1234")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == true
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_success_stopsProgress() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.showProgress) == false

        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_failure_stopsProgressAndShowsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == false
        expect(self.sut.showError) == true

        expect(self.proofManagerSpy.invokedGetTestProvider) == false
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withUnidentifiableTestProvider_showsErrorMessage() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.showProgress) == false
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_startsProgress() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == true
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == validToken
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code) == verificationInput
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_success_verificationRequired_codeIsNotEmpty_showsErrorAndResetsUIForVerification() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode

        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.secondaryButtonTitle) == String(format: .holderTokenEntryRetryCountdown, "\(10)")
        expect(self.sut.showVerification) == true
        expect(self.sut.showVerification) == true
        expect(self.sut.enableNextButton) == false
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_success_invalid_showsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_success_unknown_showsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.errorMessage) == "Unhandled: unknown"
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withPreviousRequestTokenSet_withIdentifiableTestProvider_failure_showsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: .fake, tokenValidator: tokenValidatorSpy)
        let validToken = RequestToken.fake.token
        let verificationInput = "1234"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: verificationInput)

        // Assert
        expect(self.sut.errorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
        expect(self.sut.showError) == true
    }

    // MARK: - nextButtonPressed withEmptyVerificationInput

    func test_nextButtonPressed_withEmptyVerificationInput_withInvalidTokenInput_setsErrorMessage() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let invalidTokenInput = "🍔"

        // Act
        sut.nextButtonPressed(invalidTokenInput, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidTokenInput

        expect(self.sut.errorMessage) == String.holderTokenEntryErrorInvalidCode
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withLowercaseTokenInput_createsTokenWithUppercaseInput() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validLowercaseToken = "xxx-yyyyyyyyyyyy-z2"

        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        sut.nextButtonPressed(validLowercaseToken, verificationInput: "")

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validLowercaseToken.uppercased()
        expect(self.sut.showProgress) == true
        expect(self.sut.errorMessage).to(beNil())
    }

    func test_nextButtonPressed_withEmptyVerificationInput_callsFetchProviders() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.errorMessage).to(beNil())
    }

    func test_nextButtonPressed_withEmptyVerificationInput_success_stopsProgress() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.showProgress) == false

        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
    }

    func test_nextButtonPressed_withEmptyVerificationInput_failure_stopsProgressAndShowsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.stubbedFetchCoronaTestProvidersOnErrorResult = (NSError(), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == false
        expect(self.sut.showError) == true

        expect(self.proofManagerSpy.invokedGetTestProvider) == false
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withUnidentifiableTestProvider_showsErrorMessage() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "zzz-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.showProgress) == false
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == true
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.token.token) == "YYYYYYYYYYYY"
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.code).to(beNil())
        expect(self.proofManagerSpy.invokedFetchTestResultParameters?.provider) == .fake
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.secondaryButtonTitle) == String(format: .holderTokenEntryRetryCountdown, "\(10)")
        expect(self.sut.showVerification) == true
        expect(self.sut.showVerification) == true
        expect(self.sut.enableNextButton) == false
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == "Unhandled: unknown"
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.missingParams), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == "De bewerking kan niet worden voltooid. (CTR.ProofError fout 1.)"
        expect(self.sut.showError) == true
    }

    func test_handleInput_withValidToken_showingVerification_enablesNextButtonAndShowsVerification() {

        // Arrange
        sut = TokenEntryViewModel(coordinator: holderCoordinatorSpy, proofManager: proofManagerSpy, requestToken: nil, tokenValidator: tokenValidatorSpy)
        let validToken = "XXX-YYYYYYYYYYYY-Z2"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

        sut.nextButtonPressed(validToken, verificationInput: "") // setup sut so that showVerification == true

        // Act
        sut.handleInput(validToken, verificationInput: nil)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken

        expect(self.sut.enableNextButton) == true
        expect(self.sut.showVerification) == true
        expect(self.sut.errorMessage).to(beNil())
    }
}
