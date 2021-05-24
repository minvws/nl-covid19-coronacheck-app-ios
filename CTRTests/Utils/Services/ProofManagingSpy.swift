/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ProofManagingSpy: ProofManaging {

	required init() {}

	var invokedFetchCoronaTestProviders = false
	var invokedFetchCoronaTestProvidersCount = 0
	var shouldInvokeFetchCoronaTestProvidersOnCompletion = false
	var stubbedFetchCoronaTestProvidersOnErrorResult: (Error, Void)?

	func fetchCoronaTestProviders(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?) {
		invokedFetchCoronaTestProviders = true
		invokedFetchCoronaTestProvidersCount += 1
		if shouldInvokeFetchCoronaTestProvidersOnCompletion {
			onCompletion?()
		}
		if let result = stubbedFetchCoronaTestProvidersOnErrorResult {
			onError?(result.0)
		}
	}

	var invokedFetchIssuerPublicKeys = false
	var invokedFetchIssuerPublicKeysCount = 0
	var shouldInvokeFetchIssuerPublicKeysOnCompletion = false
	var stubbedFetchIssuerPublicKeysOnErrorResult: (Error, Void)?

	func fetchIssuerPublicKeys(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?) {
		invokedFetchIssuerPublicKeys = true
		invokedFetchIssuerPublicKeysCount += 1
		if shouldInvokeFetchIssuerPublicKeysOnCompletion {
			onCompletion?()
		}
		if let result = stubbedFetchIssuerPublicKeysOnErrorResult {
			onError?(result.0)
		}
	}

	var invokedFetchTestResult = false
	var invokedFetchTestResultCount = 0
	var invokedFetchTestResultParameters: (token: RequestToken, code: String?, provider: TestProvider)?
	var invokedFetchTestResultParametersList = [(token: RequestToken, code: String?, provider: TestProvider)]()
	var stubbedFetchTestResultOnCompletionResult: (Result<TestResultWrapper, Error>, Void)?

	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		onCompletion: @escaping (Result<TestResultWrapper, Error>) -> Void) {
		invokedFetchTestResult = true
		invokedFetchTestResultCount += 1
		invokedFetchTestResultParameters = (token, code, provider)
		invokedFetchTestResultParametersList.append((token, code, provider))
		if let result = stubbedFetchTestResultOnCompletionResult {
			onCompletion(result.0)
		}
	}

	var invokedFetchNonce = false
	var invokedFetchNonceCount = 0
	var shouldInvokeFetchNonceOnCompletion = false
	var stubbedFetchNonceOnErrorResult: (Error, Void)?

	func fetchNonce(
		onCompletion: @escaping (() -> Void),
		onError: @escaping ((Error) -> Void)) {
		invokedFetchNonce = true
		invokedFetchNonceCount += 1
		if shouldInvokeFetchNonceOnCompletion {
			onCompletion()
		}
		if let result = stubbedFetchNonceOnErrorResult {
			onError(result.0)
		}
	}

	var invokedFetchSignedTestResult = false
	var invokedFetchSignedTestResultCount = 0
	var stubbedFetchSignedTestResultOnCompletionResult: (SignedTestResultState, Void)?
	var stubbedFetchSignedTestResultOnErrorResult: (Error, Void)?

	func fetchSignedTestResult(
		onCompletion: @escaping ((SignedTestResultState) -> Void),
		onError: @escaping ((Error) -> Void)) {
		invokedFetchSignedTestResult = true
		invokedFetchSignedTestResultCount += 1
		if let result = stubbedFetchSignedTestResultOnCompletionResult {
			onCompletion(result.0)
		}
		if let result = stubbedFetchSignedTestResultOnErrorResult {
			onError(result.0)
		}
	}

	var invokedGetTestProvider = false
	var invokedGetTestProviderCount = 0
	var invokedGetTestProviderParameters: (token: RequestToken, Void)?
	var invokedGetTestProviderParametersList = [(token: RequestToken, Void)]()
	var stubbedGetTestProviderResult: TestProvider!

	func getTestProvider(_ token: RequestToken) -> TestProvider? {
		invokedGetTestProvider = true
		invokedGetTestProviderCount += 1
		invokedGetTestProviderParameters = (token, ())
		invokedGetTestProviderParametersList.append((token, ()))
		return stubbedGetTestProviderResult
	}

	var invokedGetTestWrapper = false
	var invokedGetTestWrapperCount = 0
	var stubbedGetTestWrapperResult: TestResultWrapper!

	func getTestWrapper() -> TestResultWrapper? {
		invokedGetTestWrapper = true
		invokedGetTestWrapperCount += 1
		return stubbedGetTestWrapperResult
	}

	var invokedGetSignedWrapper = false
	var invokedGetSignedWrapperCount = 0
	var stubbedGetSignedWrapperResult: SignedResponse!

	func getSignedWrapper() -> SignedResponse? {
		invokedGetSignedWrapper = true
		invokedGetSignedWrapperCount += 1
		return stubbedGetSignedWrapperResult
	}

	var invokedRemoveTestWrapper = false
	var invokedRemoveTestWrapperCount = 0

	func removeTestWrapper() {
		invokedRemoveTestWrapper = true
		invokedRemoveTestWrapperCount += 1
	}

	var invokedMigrateExistingProof = false
	var invokedMigrateExistingProofCount = 0

	func migrateExistingProof() {
		invokedMigrateExistingProof = true
		invokedMigrateExistingProofCount += 1
	}
}
