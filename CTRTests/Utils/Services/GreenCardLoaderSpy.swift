/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class GreenCardLoaderSpy: GreenCardLoading {

	var invokedSignTheEventsIntoGreenCardsAndCredentials = false
	var invokedSignTheEventsIntoGreenCardsAndCredentialsCount = 0
	var stubbedSignTheEventsIntoGreenCardsAndCredentialsResponseEvaluatorResult: (RemoteGreenCards.Response, Void)?
	var stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult: (Result<RemoteGreenCards.Response, GreenCardLoader.Error>, Void)?

	func signTheEventsIntoGreenCardsAndCredentials(
		responseEvaluator: ((RemoteGreenCards.Response) -> Bool)?,
		completion: @escaping (Result<RemoteGreenCards.Response, GreenCardLoader.Error>) -> Void) {
		invokedSignTheEventsIntoGreenCardsAndCredentials = true
		invokedSignTheEventsIntoGreenCardsAndCredentialsCount += 1
		if let result = stubbedSignTheEventsIntoGreenCardsAndCredentialsResponseEvaluatorResult {
			_ = responseEvaluator?(result.0)
		}
		if let result = stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult {
			completion(result.0)
		}
	}
}
