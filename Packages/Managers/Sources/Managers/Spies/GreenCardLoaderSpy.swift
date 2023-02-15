/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import Persistence

class GreenCardLoaderSpy: GreenCardLoading {

	var invokedSignTheEventsIntoGreenCardsAndCredentials = false
	var invokedSignTheEventsIntoGreenCardsAndCredentialsCount = 0
	var invokedSignTheEventsIntoGreenCardsAndCredentialsParameters: (eventMode: EventMode?, Void)?
	var invokedSignTheEventsIntoGreenCardsAndCredentialsParametersList = [(eventMode: EventMode?, Void)]()
	var stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult: (Result<RemoteGreenCards.Response, GreenCardLoader.Error>, Void)?

	func signTheEventsIntoGreenCardsAndCredentials(
		eventMode: EventMode?,
		completion: @escaping (Result<RemoteGreenCards.Response, GreenCardLoader.Error>) -> Void) {
		invokedSignTheEventsIntoGreenCardsAndCredentials = true
		invokedSignTheEventsIntoGreenCardsAndCredentialsCount += 1
		invokedSignTheEventsIntoGreenCardsAndCredentialsParameters = (eventMode, ())
		invokedSignTheEventsIntoGreenCardsAndCredentialsParametersList.append((eventMode, ()))
		if let result = stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult {
			completion(result.0)
		}
	}
}
