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

        // isRecording = true
    }

    func test_initialState_withoutRequestToken() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)

        // Assert
//        expect(self.sut.token).to(beNil())
        expect(self.sut.showProgress) == false
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.secondaryButtonTitle).to(beNil())
        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.showError) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_initialState_withRequestToken() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)

        // Assert
//        expect(self.sut.token) == "XXX-BBBBBBBBBBBB"
        expect(self.sut.showProgress) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == false
        expect(self.sut.shouldShowNextButton) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.secondaryButtonTitle).to(beNil())
        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.showError) == false

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
        expect(self.sut.errorMessage).to(beNil())

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
        expect(self.sut.errorMessage).to(beNil())

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withValidToken_hidingVerification_enablesNextButtonAndHidesVerification() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "XXX-YYYYYYYYYYYY-Z2"

        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        sut.handleInput(validToken, verificationInput: nil)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == false
        expect(self.sut.errorMessage).to(beNil())

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withEmptyTokenInput_withEmptyVerificationInput_disablesNextButton() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let emptyVerificationInput = ""

        // Act
        sut.handleInput("", verificationInput: emptyVerificationInput)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidate) == false

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.errorMessage).to(beNil())

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withEmptyTokenInput_withNonemptyVerificationInput_enablesNextButton() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let nonemptyVerificationInput = "1234"

        // Act
        sut.handleInput("", verificationInput: nonemptyVerificationInput)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidate) == false

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.errorMessage).to(beNil())

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
        expect(self.sut.errorMessage).to(beNil())
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
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        expect(self.sut.showError) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_success_stopsProgress() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.showProgress) == false
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_failure_stopsProgressAndShowsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withUnidentifiableTestProvider_showsErrorMessage() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.showProgress) == false

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_startsProgress() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
        let validToken = RequestToken.fake.token
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        // Act
        sut.nextButtonPressed(validToken, verificationInput: "1234")

        // Assert
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == true

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_verificationRequired_codeIsNotEmpty_showsErrorAndResetsUIForVerification() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_invalid_showsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_success_unknown_showsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withNonemptyVerificationInput_withInitialRequestTokenSet_withIdentifiableTestProvider_failure_showsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: .fake)
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

        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.title) == "Testresultaat ophalen"
        expect(self.sut.message) == "Vul jouw verficatie code in.."
        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    // MARK: - nextButtonPressed withEmptyVerificationInput

    func test_nextButtonPressed_withEmptyVerificationInput_withInvalidTokenInput_setsErrorMessage() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let invalidTokenInput = "🍔"

        // Act
        sut.nextButtonPressed(invalidTokenInput, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == false
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == invalidTokenInput

        expect(self.sut.errorMessage) == String.holderTokenEntryErrorInvalidCode

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withLowercaseTokenInput_createsTokenWithUppercaseInput() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validLowercaseToken = "xxx-yyyyyyyyyyyy-z2"

        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        sut.nextButtonPressed(validLowercaseToken, verificationInput: "")

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validLowercaseToken.uppercased()
        expect(self.sut.showProgress) == true
        expect(self.sut.errorMessage).to(beNil())

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true


        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_callsFetchProviders() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true
        expect(self.sut.errorMessage).to(beNil())

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true


        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_success_stopsProgress() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.showProgress) == false
        expect(self.proofManagerSpy.invokedFetchCoronaTestProviders) == true

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_failure_stopsProgressAndShowsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
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

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        expect(self.proofManagerSpy.invokedGetTestProvider) == false

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withUnidentifiableTestProvider_showsErrorMessage() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "zzz-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode
        expect(self.sut.showProgress) == false

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_startsProgress() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.showProgress) == true

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true


        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_fetchesTestResultWithCorrectParameters() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
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

        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_complete_navigatesToListResults() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeComplete), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_pending_navigatesToListResults() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakePending), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.holderCoordinatorSpy.navigateToListResultsCalled) == true


        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_verificationRequired_codeIsEmpty_resetsUIForVerification() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
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
        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_invalid_showsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeInvalid), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_success_unknown_showsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeUnknown), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == "Unhandled: unknown"

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_withInvalidURL_showsCustomError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "xxx-yyyyyyyyyyyy-z2"
        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.failure(ProofError.invalidUrl), ())

        // Act
        sut.nextButtonPressed(validToken, verificationInput: "")

        // Assert
        expect(self.sut.errorMessage) == .holderTokenEntryErrorInvalidCode

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_nextButtonPressed_withEmptyVerificationInput_withIdentifiableTestProvider_failure_showsError() {
        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
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

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        TokenEntryViewController(viewModel: sut).assertImage()
    }

    func test_handleInput_withValidToken_showingVerification_enablesNextButtonAndShowsVerification() {

        // Arrange
        sut = mockedViewModel(withRequestToken: nil)
        let validToken = "XXX-YYYYYYYYYYYY-Z2"

        tokenValidatorSpy.stubbedValidateResult = true
        proofManagerSpy.shouldInvokeFetchCoronaTestProvidersOnCompletion = true
        proofManagerSpy.stubbedGetTestProviderResult = .fake
        proofManagerSpy.stubbedFetchTestResultOnCompletionResult = (.success(.fakeVerificationRequired), ())

        sut.nextButtonPressed(validToken, verificationInput: "") // setup sut so that shouldShowVerificationEntryField == true

        // Act
        sut.handleInput(validToken, verificationInput: nil)

        // Assert
        expect(self.tokenValidatorSpy.invokedValidateParameters?.token) == validToken

        expect(self.sut.enableNextButton) == true
        expect(self.sut.shouldShowNextButton) == true

        expect(self.sut.shouldShowTokenEntryField) == true
        expect(self.sut.shouldShowVerificationEntryField) == true
        expect(self.sut.errorMessage).to(beNil())

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
        expect(self.sut.showProgress) == false
        expect(self.sut.shouldShowTokenEntryField) == false
        expect(self.sut.shouldShowVerificationEntryField) == false
        expect(self.sut.enableNextButton) == false
        expect(self.sut.shouldShowNextButton) == false
        expect(self.sut.message).to(beNil())
        expect(self.sut.errorMessage).to(beNil())
        expect(self.sut.secondaryButtonTitle).to(beNil())
        expect(self.sut.secondaryButtonEnabled) == false
        expect(self.sut.showError) == false

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
