/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Transport
@testable import Models

class IdentitySelectionDataSourceSpy: IdentitySelectionDataSourceProtocol {

	var invokedGetIdentity = false
	var invokedGetIdentityCount = 0
	var invokedGetIdentityParameters: (uniqueIdentifier: String, Void)?
	var invokedGetIdentityParametersList = [(uniqueIdentifier: String, Void)]()
	var stubbedGetIdentityResult: EventFlow.Identity!

	func getIdentity(_ uniqueIdentifier: String) -> EventFlow.Identity? {
		invokedGetIdentity = true
		invokedGetIdentityCount += 1
		invokedGetIdentityParameters = (uniqueIdentifier, ())
		invokedGetIdentityParametersList.append((uniqueIdentifier, ()))
		return stubbedGetIdentityResult
	}

	var invokedGetIdentityInformation = false
	var invokedGetIdentityInformationCount = 0
	var invokedGetIdentityInformationParameters: (matchingBlobIds: [[String]], Void)?
	var invokedGetIdentityInformationParametersList = [(matchingBlobIds: [[String]], Void)]()
	var stubbedGetIdentityInformationResult: [(blobIds: [String], name: String, eventCountInformation: String)]! = []

	func getIdentityInformation(matchingBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)] {
		invokedGetIdentityInformation = true
		invokedGetIdentityInformationCount += 1
		invokedGetIdentityInformationParameters = (matchingBlobIds, ())
		invokedGetIdentityInformationParametersList.append((matchingBlobIds, ()))
		return stubbedGetIdentityInformationResult
	}

	var invokedGetEventOveriew = false
	var invokedGetEventOveriewCount = 0
	var invokedGetEventOveriewParameters: (blobIds: [String], Void)?
	var invokedGetEventOveriewParametersList = [(blobIds: [String], Void)]()
	var stubbedGetEventOveriewResult: [[String]]! = []

	func getEventOveriew(blobIds: [String]) -> [[String]] {
		invokedGetEventOveriew = true
		invokedGetEventOveriewCount += 1
		invokedGetEventOveriewParameters = (blobIds, ())
		invokedGetEventOveriewParametersList.append((blobIds, ()))
		return stubbedGetEventOveriewResult
	}

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
