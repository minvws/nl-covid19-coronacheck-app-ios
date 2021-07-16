/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class PaperCertificateCoordinatorDelegateSpy: PaperCertificateCoordinatorDelegate, OpenUrlProtocol {

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

	var invokedUserWishesToEnterToken = false
	var invokedUserWishesToEnterTokenCount = 0

	func userWishesToEnterToken() {
		invokedUserWishesToEnterToken = true
		invokedUserWishesToEnterTokenCount += 1
	}

	var invokedUserWishesToScanCertificate = false
	var invokedUserWishesToScanCertificateCount = 0

	func userWishesToScanCertificate() {
		invokedUserWishesToScanCertificate = true
		invokedUserWishesToScanCertificateCount += 1
	}

	var invokedUserWishesToCreateACertificate = false
	var invokedUserWishesToCreateACertificateCount = 0
	var invokedUserWishesToCreateACertificateParameters: (message: String, Void)?
	var invokedUserWishesToCreateACertificateParametersList = [(message: String, Void)]()

	func userWishesToCreateACertificate(message: String) {
		invokedUserWishesToCreateACertificate = true
		invokedUserWishesToCreateACertificateCount += 1
		invokedUserWishesToCreateACertificateParameters = (message, ())
		invokedUserWishesToCreateACertificateParametersList.append((message, ()))
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
