/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import Persistence

public class GreenCardLoaderSpy: GreenCardLoading {
	
	public init() {}

	public var invokedSignTheEventsIntoGreenCardsAndCredentials = false
	public var invokedSignTheEventsIntoGreenCardsAndCredentialsCount = 0
	public var invokedSignTheEventsIntoGreenCardsAndCredentialsParameters: (eventMode: EventMode?, Void)?
	public var invokedSignTheEventsIntoGreenCardsAndCredentialsParametersList = [(eventMode: EventMode?, Void)]()
	public var stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult: (Result<RemoteGreenCards.Response, GreenCardLoader.Error>, Void)?

	public func signTheEventsIntoGreenCardsAndCredentials(
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
