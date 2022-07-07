/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

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

	var invokedContinueToGGDPortal = false
	var invokedContinueToGGDPortalCount = 0
	var invokedContinueToGGDPortalParameters: (eventMode: EventMode, Void)?
	var invokedContinueToGGDPortalParametersList = [(eventMode: EventMode, Void)]()

	func continueToGGDPortal(eventMode: EventMode) {
		invokedContinueToGGDPortal = true
		invokedContinueToGGDPortalCount += 1
		invokedContinueToGGDPortalParameters = (eventMode, ())
		invokedContinueToGGDPortalParametersList.append((eventMode, ()))
	}
}
