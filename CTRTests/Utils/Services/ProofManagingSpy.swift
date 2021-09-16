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
	var stubbedFetchIssuerPublicKeysOnCompletionResult: (Result<Data, ServerError>, Void)?

	func fetchIssuerPublicKeys(onCompletion: ((Result<Data, ServerError>) -> Void)?) {
		invokedFetchIssuerPublicKeys = true
		invokedFetchIssuerPublicKeysCount += 1
		if let result = stubbedFetchIssuerPublicKeysOnCompletionResult {
			onCompletion?(result.0)
		}
	}
}
