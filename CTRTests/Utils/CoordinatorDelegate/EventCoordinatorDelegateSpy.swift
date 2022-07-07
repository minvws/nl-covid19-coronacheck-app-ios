/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class EventCoordinatorDelegateSpy: EventCoordinatorDelegate, OpenUrlProtocol, Dismissable {

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

	var invokedauthenticationScreenDidFinish = false
	var invokedauthenticationScreenDidFinishCount = 0
	var invokedauthenticationScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedauthenticationScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func authenticationScreenDidFinish(_ result: EventScreenResult) {
		invokedauthenticationScreenDidFinish = true
		invokedauthenticationScreenDidFinishCount += 1
		invokedauthenticationScreenDidFinishParameters = (result, ())
		invokedauthenticationScreenDidFinishParametersList.append((result, ()))
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
	var invokedOpenUrlParameters: (url: URL, inApp: Bool)?
	var invokedOpenUrlParametersList = [(url: URL, inApp: Bool)]()

	func openUrl(_ url: URL, inApp: Bool) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, inApp)
		invokedOpenUrlParametersList.append((url, inApp))
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
