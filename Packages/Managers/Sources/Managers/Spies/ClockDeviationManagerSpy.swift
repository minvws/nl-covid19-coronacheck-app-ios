/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

class ClockDeviationManagerSpy: ClockDeviationManaging {

	var invokedHasSignificantDeviationGetter = false
	var invokedHasSignificantDeviationGetterCount = 0
	var stubbedHasSignificantDeviation: Bool!

	var hasSignificantDeviation: Bool? {
		invokedHasSignificantDeviationGetter = true
		invokedHasSignificantDeviationGetterCount += 1
		return stubbedHasSignificantDeviation
	}

	var invokedObservatoryGetter = false
	var invokedObservatoryGetterCount = 0
	var stubbedObservatory: Observatory<Bool>!

	var observatory: Observatory<Bool> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	var invokedUpdate = false
	var invokedUpdateCount = 0
	var invokedUpdateParameters: (serverHeaderDate: String, ageHeader: String?)?
	var invokedUpdateParametersList = [(serverHeaderDate: String, ageHeader: String?)]()

	func update(serverHeaderDate: String, ageHeader: String?) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (serverHeaderDate, ageHeader)
		invokedUpdateParametersList.append((serverHeaderDate, ageHeader))
	}

	var invokedUpdateServerResponseDateTime = false
	var invokedUpdateServerResponseDateTimeCount = 0
	var invokedUpdateServerResponseDateTimeParameters: (serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t)?
	var invokedUpdateServerResponseDateTimeParametersList = [(serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t)]()

	func update(serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t) {
		invokedUpdateServerResponseDateTime = true
		invokedUpdateServerResponseDateTimeCount += 1
		invokedUpdateServerResponseDateTimeParameters = (serverResponseDateTime, localResponseDateTime, localResponseSystemUptime)
		invokedUpdateServerResponseDateTimeParametersList.append((serverResponseDateTime, localResponseDateTime, localResponseSystemUptime))
	}
}
