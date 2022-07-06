/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OpenIdManagerSpy: OpenIdManaging {

	var invokedRequestAccessToken = false
	var invokedRequestAccessTokenCount = 0
	var invokedRequestAccessTokenParameters: (issuerConfiguration: IssuerConfiguration, Void)?
	var invokedRequestAccessTokenParametersList = [(issuerConfiguration: IssuerConfiguration, Void)]()
	var stubbedRequestAccessTokenOnCompletionResult: (TVSAuthorizationToken, Void)?
	var stubbedRequestAccessTokenOnErrorResult: (Error?, Void)?

	func requestAccessToken(
		issuerConfiguration: IssuerConfiguration,
		onCompletion: @escaping (TVSAuthorizationToken) -> Void,
		onError: @escaping (Error?) -> Void) {
		invokedRequestAccessToken = true
		invokedRequestAccessTokenCount += 1
		invokedRequestAccessTokenParameters = (issuerConfiguration, ())
		invokedRequestAccessTokenParametersList.append((issuerConfiguration, ()))
		if let result = stubbedRequestAccessTokenOnCompletionResult {
			onCompletion(result.0)
		}
		if let result = stubbedRequestAccessTokenOnErrorResult {
			onError(result.0)
		}
	}
}
