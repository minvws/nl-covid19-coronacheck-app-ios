/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	var invokedAuthenticationScreenDidFinish = false
	var invokedAuthenticationScreenDidFinishCount = 0
	var invokedAuthenticationScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedAuthenticationScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func authenticationScreenDidFinish(_ result: EventScreenResult) {
		invokedAuthenticationScreenDidFinish = true
		invokedAuthenticationScreenDidFinishCount += 1
		invokedAuthenticationScreenDidFinishParameters = (result, ())
		invokedAuthenticationScreenDidFinishParametersList.append((result, ()))
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

	var invokedShowHintsScreenDidFinish = false
	var invokedShowHintsScreenDidFinishCount = 0
	var invokedShowHintsScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedShowHintsScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func showHintsScreenDidFinish(_ result: EventScreenResult) {
		invokedShowHintsScreenDidFinish = true
		invokedShowHintsScreenDidFinishCount += 1
		invokedShowHintsScreenDidFinishParameters = (result, ())
		invokedShowHintsScreenDidFinishParametersList.append((result, ()))
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()

	func openUrl(_ url: URL) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
	}
}
