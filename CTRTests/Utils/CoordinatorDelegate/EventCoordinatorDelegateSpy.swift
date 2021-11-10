/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class EventCoordinatorDelegateSpy: EventCoordinatorDelegate, OpenUrlProtocol {

	var invokedEventStartScreenDidFinish = false
	var invokedEventStartScreenDidFinishCount = 0
	var invokedEventStartScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedEventStartScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func eventStartScreenDidFinish(_ result: EventScreenResult) {
		invokedEventStartScreenDidFinish = true
		invokedEventStartScreenDidFinishCount += 1
		invokedEventStartScreenDidFinishParameters = (result, ())
		invokedEventStartScreenDidFinishParametersList.append((result, ()))
	}

	var invokedLoginTVSScreenDidFinish = false
	var invokedLoginTVSScreenDidFinishCount = 0
	var invokedLoginTVSScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedLoginTVSScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func loginTVSScreenDidFinish(_ result: EventScreenResult) {
		invokedLoginTVSScreenDidFinish = true
		invokedLoginTVSScreenDidFinishCount += 1
		invokedLoginTVSScreenDidFinishParameters = (result, ())
		invokedLoginTVSScreenDidFinishParametersList.append((result, ()))
	}

	var invokedFetchEventsScreenDidFinish = false
	var invokedFetchEventsScreenDidFinishCount = 0
	var invokedFetchEventsScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedFetchEventsScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func fetchEventsScreenDidFinish(_ result: EventScreenResult) {
		invokedFetchEventsScreenDidFinish = true
		invokedFetchEventsScreenDidFinishCount += 1
		invokedFetchEventsScreenDidFinishParameters = (result, ())
		invokedFetchEventsScreenDidFinishParametersList.append((result, ()))
	}

	var invokedListEventsScreenDidFinish = false
	var invokedListEventsScreenDidFinishCount = 0
	var invokedListEventsScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedListEventsScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func listEventsScreenDidFinish(_ result: EventScreenResult) {
		invokedListEventsScreenDidFinish = true
		invokedListEventsScreenDidFinishCount += 1
		invokedListEventsScreenDidFinishParameters = (result, ())
		invokedListEventsScreenDidFinishParametersList.append((result, ()))
	}

	var invokedStartWithPositiveTest = false
	var invokedStartWithPositiveTestCount = 0
	var invokedStartWithPositiveTestParameters: (tvsToken: TVSAuthorizationToken?, Void)?
	var invokedStartWithPositiveTestParametersList = [(tvsToken: TVSAuthorizationToken?, Void)]()

	func startWithPositiveTest(tvsToken: TVSAuthorizationToken?) {
		invokedStartWithPositiveTest = true
		invokedStartWithPositiveTestCount += 1
		invokedStartWithPositiveTestParameters = (tvsToken, ())
		invokedStartWithPositiveTestParametersList.append((tvsToken, ()))
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, inApp: Bool)?
	var invokedOpenUrlParametersList = [(url: URL, inApp: Bool)]()

	func openUrl(_ url: URL, inApp: Bool) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, inApp)
		invokedOpenUrlParametersList.append((url, inApp))
	}
}
