/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import Persistence

class AlternativeRouteFlowDelegateSpy: AlternativeRouteFlowDelegate {

	var invokedCanceledAlternativeRoute = false
	var invokedCanceledAlternativeRouteCount = 0

	func canceledAlternativeRoute() {
		invokedCanceledAlternativeRoute = true
		invokedCanceledAlternativeRouteCount += 1
	}

	var invokedBackToMyOverview = false
	var invokedBackToMyOverviewCount = 0

	func backToMyOverview() {
		invokedBackToMyOverview = true
		invokedBackToMyOverviewCount += 1
	}

	var invokedContinueToPap = false
	var invokedContinueToPapCount = 0
	var invokedContinueToPapParameters: (eventMode: EventMode, Void)?
	var invokedContinueToPapParametersList = [(eventMode: EventMode, Void)]()

	func continueToPap(eventMode: EventMode) {
		invokedContinueToPap = true
		invokedContinueToPapCount += 1
		invokedContinueToPapParameters = (eventMode, ())
		invokedContinueToPapParametersList.append((eventMode, ()))
	}
}
