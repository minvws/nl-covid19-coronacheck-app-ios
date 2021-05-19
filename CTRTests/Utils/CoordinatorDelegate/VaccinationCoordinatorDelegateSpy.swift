/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VaccinationCoordinatorDelegateSpy: VaccinationCoordinatorDelegate, OpenUrlProtocol {

	var invokedVaccinationStartScreenDidFinish = false
	var invokedVaccinationStartScreenDidFinishCount = 0
	var invokedVaccinationStartScreenDidFinishParameters: (result: VaccinationScreenResult, Void)?
	var invokedVaccinationStartScreenDidFinishParametersList = [(result: VaccinationScreenResult, Void)]()

	func vaccinationStartScreenDidFinish(_ result: VaccinationScreenResult) {
		invokedVaccinationStartScreenDidFinish = true
		invokedVaccinationStartScreenDidFinishCount += 1
		invokedVaccinationStartScreenDidFinishParameters = (result, ())
		invokedVaccinationStartScreenDidFinishParametersList.append((result, ()))
	}

	var invokedFetchEventsScreenDidFinish = false
	var invokedFetchEventsScreenDidFinishCount = 0
	var invokedFetchEventsScreenDidFinishParameters: (result: VaccinationScreenResult, Void)?
	var invokedFetchEventsScreenDidFinishParametersList = [(result: VaccinationScreenResult, Void)]()

	func fetchEventsScreenDidFinish(_ result: VaccinationScreenResult) {
		invokedFetchEventsScreenDidFinish = true
		invokedFetchEventsScreenDidFinishCount += 1
		invokedFetchEventsScreenDidFinishParameters = (result, ())
		invokedFetchEventsScreenDidFinishParametersList.append((result, ()))
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
