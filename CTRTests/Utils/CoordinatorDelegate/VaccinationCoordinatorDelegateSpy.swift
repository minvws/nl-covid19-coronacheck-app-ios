/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VaccinationCoordinatorDelegateSpy: EventCoordinatorDelegate, OpenUrlProtocol {

	var invokedVaccinationStartScreenDidFinish = false
	var invokedVaccinationStartScreenDidFinishCount = 0
	var invokedVaccinationStartScreenDidFinishParameters: (result: EventScreenResult, Void)?
	var invokedVaccinationStartScreenDidFinishParametersList = [(result: EventScreenResult, Void)]()

	func vaccinationStartScreenDidFinish(_ result: EventScreenResult) {
		invokedVaccinationStartScreenDidFinish = true
		invokedVaccinationStartScreenDidFinishCount += 1
		invokedVaccinationStartScreenDidFinishParameters = (result, ())
		invokedVaccinationStartScreenDidFinishParametersList.append((result, ()))
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
