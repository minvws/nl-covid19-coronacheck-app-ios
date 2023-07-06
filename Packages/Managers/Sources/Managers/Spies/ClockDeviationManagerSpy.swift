/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public class ClockDeviationManagerSpy: ClockDeviationManaging {
	
	public init() {}

	public var invokedHasSignificantDeviationGetter = false
	public var invokedHasSignificantDeviationGetterCount = 0
	public var stubbedHasSignificantDeviation: Bool!

	public var hasSignificantDeviation: Bool? {
		invokedHasSignificantDeviationGetter = true
		invokedHasSignificantDeviationGetterCount += 1
		return stubbedHasSignificantDeviation
	}

	public var invokedObservatoryGetter = false
	public var invokedObservatoryGetterCount = 0
	public var stubbedObservatory: Observatory<Bool>!

	public var observatory: Observatory<Bool> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	public var invokedUpdate = false
	public var invokedUpdateCount = 0
	public var invokedUpdateParameters: (serverHeaderDate: String, ageHeader: String?)?
	public var invokedUpdateParametersList = [(serverHeaderDate: String, ageHeader: String?)]()

	public func update(serverHeaderDate: String, ageHeader: String?) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (serverHeaderDate, ageHeader)
		invokedUpdateParametersList.append((serverHeaderDate, ageHeader))
	}

	public var invokedUpdateServerResponseDateTime = false
	public var invokedUpdateServerResponseDateTimeCount = 0
	public var invokedUpdateServerResponseDateTimeParameters: (serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t)?
	public var invokedUpdateServerResponseDateTimeParametersList = [(serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t)]()

	public func update(serverResponseDateTime: Date, localResponseDateTime: Date, localResponseSystemUptime: __darwin_time_t) {
		invokedUpdateServerResponseDateTime = true
		invokedUpdateServerResponseDateTimeCount += 1
		invokedUpdateServerResponseDateTimeParameters = (serverResponseDateTime, localResponseDateTime, localResponseSystemUptime)
		invokedUpdateServerResponseDateTimeParametersList.append((serverResponseDateTime, localResponseDateTime, localResponseSystemUptime))
	}
}
