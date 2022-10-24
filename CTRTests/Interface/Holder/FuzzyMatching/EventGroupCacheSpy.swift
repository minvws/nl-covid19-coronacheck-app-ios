/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
@testable import Transport

class EventGroupCacheSpy: EventGroupCacheProtocol {

	var invokedGetEventResultWrapper = false
	var invokedGetEventResultWrapperCount = 0
	var invokedGetEventResultWrapperParameters: (uniqueIdentifier: String, Void)?
	var invokedGetEventResultWrapperParametersList = [(uniqueIdentifier: String, Void)]()
	var stubbedGetEventResultWrapperResult: EventFlow.EventResultWrapper!

	func getEventResultWrapper(_ uniqueIdentifier: String) -> EventFlow.EventResultWrapper? {
		invokedGetEventResultWrapper = true
		invokedGetEventResultWrapperCount += 1
		invokedGetEventResultWrapperParameters = (uniqueIdentifier, ())
		invokedGetEventResultWrapperParametersList.append((uniqueIdentifier, ()))
		return stubbedGetEventResultWrapperResult
	}

	var invokedGetEUCreditialAttributes = false
	var invokedGetEUCreditialAttributesCount = 0
	var invokedGetEUCreditialAttributesParameters: (uniqueIdentifier: String, Void)?
	var invokedGetEUCreditialAttributesParametersList = [(uniqueIdentifier: String, Void)]()
	var stubbedGetEUCreditialAttributesResult: EuCredentialAttributes!

	func getEUCreditialAttributes(_ uniqueIdentifier: String) -> EuCredentialAttributes? {
		invokedGetEUCreditialAttributes = true
		invokedGetEUCreditialAttributesCount += 1
		invokedGetEUCreditialAttributesParameters = (uniqueIdentifier, ())
		invokedGetEUCreditialAttributesParametersList.append((uniqueIdentifier, ()))
		return stubbedGetEUCreditialAttributesResult
	}
}
