/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import OpenIDConnect

class OpenIdManagerSpy: OpenIDConnectManaging {

	var invokedRequestAccessToken = false
	var invokedRequestAccessTokenCount = 0
	var invokedRequestAccessTokenParameters: (issuerConfiguration: OpenIDConnectConfiguration, presentingViewController: UIViewController?, openIDConnectState: OpenIDConnectState?)?
	var invokedRequestAccessTokenParametersList = [(issuerConfiguration: OpenIDConnectConfiguration, presentingViewController: UIViewController?, openIDConnectState: OpenIDConnectState?)]()
	var stubbedRequestAccessTokenOnCompletionResult: (OpenIDConnectToken, Void)?
	var stubbedRequestAccessTokenOnErrorResult: (Error?, Void)?

	func requestAccessToken(
		issuerConfiguration: OpenIDConnectConfiguration,
		presentingViewController: UIViewController?,
		openIDConnectState: OpenIDConnectState?,
		onCompletion: @escaping (OpenIDConnectToken) -> Void,
		onError: @escaping (Error?) -> Void) {
		invokedRequestAccessToken = true
		invokedRequestAccessTokenCount += 1
		invokedRequestAccessTokenParameters = (issuerConfiguration, presentingViewController, openIDConnectState)
		invokedRequestAccessTokenParametersList.append((issuerConfiguration, presentingViewController, openIDConnectState))
		if let result = stubbedRequestAccessTokenOnCompletionResult {
			onCompletion(result.0)
		}
		if let result = stubbedRequestAccessTokenOnErrorResult {
			onError(result.0)
		}
	}
}
