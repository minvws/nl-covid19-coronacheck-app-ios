/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Transport

class IdentitySelectionDataSourceSpy: IdentitySelectionDataSourceProtocol {

	var invokedCacheGetter = false
	var invokedCacheGetterCount = 0
	var stubbedCache: EventGroupCacheProtocol!

	var cache: EventGroupCacheProtocol {
		invokedCacheGetter = true
		invokedCacheGetterCount += 1
		return stubbedCache
	}

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
	var invokedGetIdentityInformationParameters: (nestedBlobIds: [[String]], Void)?
	var invokedGetIdentityInformationParametersList = [(nestedBlobIds: [[String]], Void)]()
	var stubbedGetIdentityInformationResult: [(blobIds: [String], name: String, eventCountInformation: String)]! = []

	func getIdentityInformation(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)] {
		invokedGetIdentityInformation = true
		invokedGetIdentityInformationCount += 1
		invokedGetIdentityInformationParameters = (nestedBlobIds, ())
		invokedGetIdentityInformationParametersList.append((nestedBlobIds, ()))
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
}
