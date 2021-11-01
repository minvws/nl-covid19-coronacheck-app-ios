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

	var invokedIsAuthorizationInProgressSetter = false
	var invokedIsAuthorizationInProgressSetterCount = 0
	var invokedIsAuthorizationInProgress: Bool?
	var invokedIsAuthorizationInProgressList = [Bool]()
	var invokedIsAuthorizationInProgressGetter = false
	var invokedIsAuthorizationInProgressGetterCount = 0
	var stubbedIsAuthorizationInProgress: Bool! = false

	var isAuthorizationInProgress: Bool {
		set {
			invokedIsAuthorizationInProgressSetter = true
			invokedIsAuthorizationInProgressSetterCount += 1
			invokedIsAuthorizationInProgress = newValue
			invokedIsAuthorizationInProgressList.append(newValue)
		}
		get {
			invokedIsAuthorizationInProgressGetter = true
			invokedIsAuthorizationInProgressGetterCount += 1
			return stubbedIsAuthorizationInProgress
		}
	}

	var invokedRequestAccessToken = false
	var invokedRequestAccessTokenCount = 0
	var stubbedRequestAccessTokenOnCompletionResult: (String?, Void)?
	var stubbedRequestAccessTokenOnErrorResult: (Error?, Void)?

	func requestAccessToken(
		onCompletion: @escaping (String?) -> Void,
		onError: @escaping (Error?) -> Void) {
		invokedRequestAccessToken = true
		invokedRequestAccessTokenCount += 1
		if let result = stubbedRequestAccessTokenOnCompletionResult {
			onCompletion(result.0)
		}
		if let result = stubbedRequestAccessTokenOnErrorResult {
			onError(result.0)
		}
	}
}
