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
	var stubbedFetchIssuerPublicKeysOnCompletionResult: (Result<Data, NetworkError>, Void)?

	func fetchIssuerPublicKeys(onCompletion: ((Result<Data, NetworkError>) -> Void)?) {
		invokedFetchIssuerPublicKeys = true
		invokedFetchIssuerPublicKeysCount += 1
		if let result = stubbedFetchIssuerPublicKeysOnCompletionResult {
			onCompletion?(result.0)
		}
	}

	var invokedFetchTestResult = false
	var invokedFetchTestResultCount = 0
	var invokedFetchTestResultParameters: (token: RequestToken, code: String?, provider: TestProvider)?
	var invokedFetchTestResultParametersList = [(token: RequestToken, code: String?, provider: TestProvider)]()
	var stubbedFetchTestResultOnCompletionResult: (Result<RemoteEvent, Error>, Void)?

	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		onCompletion: @escaping (Result<RemoteEvent, Error>) -> Void) {
		invokedFetchTestResult = true
		invokedFetchTestResultCount += 1
		invokedFetchTestResultParameters = (token, code, provider)
		invokedFetchTestResultParametersList.append((token, code, provider))
		if let result = stubbedFetchTestResultOnCompletionResult {
			onCompletion(result.0)
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
}
