/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class PaperCertificateCoordinatorDelegateSpy: PaperCertificateCoordinatorDelegate, OpenUrlProtocol {

	var invokedUserWishesMoreInformationOnSelfPrintedProof = false
	var invokedUserWishesMoreInformationOnSelfPrintedProofCount = 0

	func userWishesMoreInformationOnSelfPrintedProof() {
		invokedUserWishesMoreInformationOnSelfPrintedProof = true
		invokedUserWishesMoreInformationOnSelfPrintedProofCount += 1
	}

	var invokedUserWishesMoreInformationOnNoInputToken = false
	var invokedUserWishesMoreInformationOnNoInputTokenCount = 0

	func userWishesMoreInformationOnNoInputToken() {
		invokedUserWishesMoreInformationOnNoInputToken = true
		invokedUserWishesMoreInformationOnNoInputTokenCount += 1
	}

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

	var invokedUserWishesToSeeScannedEvent = false
	var invokedUserWishesToSeeScannedEventCount = 0
	var invokedUserWishesToSeeScannedEventParameters: (event: RemoteEvent, Void)?
	var invokedUserWishesToSeeScannedEventParametersList = [(event: RemoteEvent, Void)]()

	func userWishesToSeeScannedEvent(_ event: RemoteEvent) {
		invokedUserWishesToSeeScannedEvent = true
		invokedUserWishesToSeeScannedEventCount += 1
		invokedUserWishesToSeeScannedEventParameters = (event, ())
		invokedUserWishesToSeeScannedEventParametersList.append((event, ()))
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

	var invokedDisplayError = false
	var invokedDisplayErrorCount = 0
	var invokedDisplayErrorParameters: (content: Content, Void)?
	var invokedDisplayErrorParametersList = [(content: Content, Void)]()
	var shouldInvokeDisplayErrorBackAction = false

	func displayError(content: Content, backAction: @escaping () -> Void) {
		invokedDisplayError = true
		invokedDisplayErrorCount += 1
		invokedDisplayErrorParameters = (content, ())
		invokedDisplayErrorParametersList.append((content, ()))
		if shouldInvokeDisplayErrorBackAction {
			backAction()
		}
	}

	var invokedUserWishesToGoBackToScanCertificate = false
	var invokedUserWishesToGoBackToScanCertificateCount = 0

	func userWishesToGoBackToScanCertificate() {
		invokedUserWishesToGoBackToScanCertificate = true
		invokedUserWishesToGoBackToScanCertificateCount += 1
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
