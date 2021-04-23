/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OpenIdManagerSpy: OpenIdManaging {

	required init() {}

	var invokedRequestAccessToken = false
	var invokedRequestAccessTokenCount = 0
	var invokedRequestAccessTokenParameters: (presenter: UIViewController, Void)?
	var invokedRequestAccessTokenParametersList = [(presenter: UIViewController, Void)]()
	var stubbedRequestAccessTokenOnCompletionResult: (String?, Void)?
	var stubbedRequestAccessTokenOnErrorResult: (Error?, Void)?

	func requestAccessToken(
		presenter: UIViewController,
		onCompletion: @escaping (String?) -> Void,
		onError: @escaping (Error?) -> Void) {
		invokedRequestAccessToken = true
		invokedRequestAccessTokenCount += 1
		invokedRequestAccessTokenParameters = (presenter, ())
		invokedRequestAccessTokenParametersList.append((presenter, ()))
		if let result = stubbedRequestAccessTokenOnCompletionResult {
			onCompletion(result.0)
		}
		if let result = stubbedRequestAccessTokenOnErrorResult {
			onError(result.0)
		}
	}
}
