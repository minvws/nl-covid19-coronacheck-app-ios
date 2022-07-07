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

	var invokedStartPortalFlow = false
	var invokedStartPortalFlowCount = 0
	var invokedStartPortalFlowParameters: (eventMode: EventMode, Void)?
	var invokedStartPortalFlowParametersList = [(eventMode: EventMode, Void)]()

	func startPortalFlow(eventMode: EventMode) {
		invokedStartPortalFlow = true
		invokedStartPortalFlowCount += 1
		invokedStartPortalFlowParameters = (eventMode, ())
		invokedStartPortalFlowParametersList.append((eventMode, ()))
	}
}
