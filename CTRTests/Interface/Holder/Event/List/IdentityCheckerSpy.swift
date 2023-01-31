/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import TestingShared
import Persistence

class IdentityCheckerSpy: IdentityCheckerProtocol {

	var invokedCompare = false
	var invokedCompareCount = 0
	var invokedCompareParameters: (eventGroups: [EventGroup], remoteEvents: [RemoteEvent])?
	var invokedCompareParametersList = [(eventGroups: [EventGroup], remoteEvents: [RemoteEvent])]()
	var stubbedCompareResult: Bool! = false

	func compare(eventGroups: [EventGroup], with remoteEvents: [RemoteEvent]) -> Bool {
		invokedCompare = true
		invokedCompareCount += 1
		invokedCompareParameters = (eventGroups, remoteEvents)
		invokedCompareParametersList.append((eventGroups, remoteEvents))
		return stubbedCompareResult
	}
}
