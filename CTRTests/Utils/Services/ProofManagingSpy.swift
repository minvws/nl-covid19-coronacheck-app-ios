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
}
