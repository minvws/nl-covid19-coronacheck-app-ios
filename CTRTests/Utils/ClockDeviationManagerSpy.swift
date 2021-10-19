/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class ClockDeviationManagerSpy: ClockDeviationManaging {

	required init() {}

	var invokedHasSignificantDeviationGetter = false
	var invokedHasSignificantDeviationGetterCount = 0
	var stubbedHasSignificantDeviation: Bool!

	var hasSignificantDeviation: Bool? {
		invokedHasSignificantDeviationGetter = true
		invokedHasSignificantDeviationGetterCount += 1
		return stubbedHasSignificantDeviation
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

	var invokedAppendDeviationChangeObserver = false
	var invokedAppendDeviationChangeObserverCount = 0
	var stubbedAppendDeviationChangeObserverObserverResult: (Bool, Void)?
	var stubbedAppendDeviationChangeObserverResult: ClockDeviationManager.ObserverToken!

	func appendDeviationChangeObserver(_ observer: @escaping (Bool) -> Void) -> ClockDeviationManager.ObserverToken {
		invokedAppendDeviationChangeObserver = true
		invokedAppendDeviationChangeObserverCount += 1
		if let result = stubbedAppendDeviationChangeObserverObserverResult {
			observer(result.0)
		}
		return stubbedAppendDeviationChangeObserverResult
	}

	var invokedRemoveDeviationChangeObserver = false
	var invokedRemoveDeviationChangeObserverCount = 0
	var invokedRemoveDeviationChangeObserverParameters: (token: ClockDeviationManager.ObserverToken, Void)?
	var invokedRemoveDeviationChangeObserverParametersList = [(token: ClockDeviationManager.ObserverToken, Void)]()

	func removeDeviationChangeObserver(token: ClockDeviationManager.ObserverToken) {
		invokedRemoveDeviationChangeObserver = true
		invokedRemoveDeviationChangeObserverCount += 1
		invokedRemoveDeviationChangeObserverParameters = (token, ())
		invokedRemoveDeviationChangeObserverParametersList.append((token, ()))
	}
}
