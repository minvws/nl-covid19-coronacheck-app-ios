/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class IdentitySelectionDataSourceSpy: IdentitySelectionDataSourceProtocol {

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
