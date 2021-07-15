/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class PaperCertificateCoordinatorDelegateSpy: PaperCertificateCoordinatorDelegate {

	var invokedUserDidSubmitPaperCertificateToken = false
	var invokedUserDidSubmitPaperCertificateTokenCount = 0
	var invokedUserDidSubmitPaperCertificateTokenParameters: (token: String, Void)?
	var invokedUserDidSubmitPaperCertificateTokenParametersList = [(token: String, Void)]()

	func userDidSubmitPaperCertificateToken(token: String) {
		invokedUserDidSubmitPaperCertificateToken = true
		invokedUserDidSubmitPaperCertificateTokenCount += 1
		invokedUserDidSubmitPaperCertificateTokenParameters = (token, ())
		invokedUserDidSubmitPaperCertificateTokenParametersList.append((token, ()))
	}

	var invokedPresentInformationPage = false
	var invokedPresentInformationPageCount = 0
	var invokedPresentInformationPageParameters: (title: String, body: String, hideBodyForScreenCapture: Bool)?
	var invokedPresentInformationPageParametersList = [(title: String, body: String, hideBodyForScreenCapture: Bool)]()

	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool) {
		invokedPresentInformationPage = true
		invokedPresentInformationPageCount += 1
		invokedPresentInformationPageParameters = (title, body, hideBodyForScreenCapture)
		invokedPresentInformationPageParametersList.append((title, body, hideBodyForScreenCapture))
	}

	var invokedUserWantsToGoBackToDashboard = false
	var invokedUserWantsToGoBackToDashboardCount = 0

	func userWantsToGoBackToDashboard() {
		invokedUserWantsToGoBackToDashboard = true
		invokedUserWantsToGoBackToDashboardCount += 1
	}

	var invokedUserWantsToGoBackToTokenEntry = false
	var invokedUserWantsToGoBackToTokenEntryCount = 0

	func userWantsToGoBackToTokenEntry() {
		invokedUserWantsToGoBackToTokenEntry = true
		invokedUserWantsToGoBackToTokenEntryCount += 1
	}

	var invokedUserWantToToGoEvents = false
	var invokedUserWantToToGoEventsCount = 0
	var invokedUserWantToToGoEventsParameters: (event: RemoteEvent, Void)?
	var invokedUserWantToToGoEventsParametersList = [(event: RemoteEvent, Void)]()

	func userWantToToGoEvents(_ event: RemoteEvent) {
		invokedUserWantToToGoEvents = true
		invokedUserWantToToGoEventsCount += 1
		invokedUserWantToToGoEventsParameters = (event, ())
		invokedUserWantToToGoEventsParametersList.append((event, ()))
	}
}
