/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import OpenIDConnect

class OpenIdManagerSpy: OpenIdManaging {

	var invokedRequestAccessToken = false
	var invokedRequestAccessTokenCount = 0
	var invokedRequestAccessTokenParameters: (issuerConfiguration: IssuerConfiguration, presentingViewController: UIViewController?)?
	var invokedRequestAccessTokenParametersList = [(issuerConfiguration: IssuerConfiguration, presentingViewController: UIViewController?)]()
	var stubbedRequestAccessTokenOnCompletionResult: (OpenIdManagerToken, Void)?
	var stubbedRequestAccessTokenOnErrorResult: (Error?, Void)?

	func requestAccessToken(
		issuerConfiguration: IssuerConfiguration,
		presentingViewController: UIViewController?,
		onCompletion: @escaping (OpenIdManagerToken) -> Void,
		onError: @escaping (Error?) -> Void) {
		invokedRequestAccessToken = true
		invokedRequestAccessTokenCount += 1
		invokedRequestAccessTokenParameters = (issuerConfiguration, presentingViewController)
		invokedRequestAccessTokenParametersList.append((issuerConfiguration, presentingViewController))
		if let result = stubbedRequestAccessTokenOnCompletionResult {
			onCompletion(result.0)
		}
		if let result = stubbedRequestAccessTokenOnErrorResult {
			onError(result.0)
		}
	}
}
