/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
// swiftlint:disable file_length

@testable import CTR
import XCTest

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
