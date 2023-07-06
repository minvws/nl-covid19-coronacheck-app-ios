/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import Foundation
@testable import CTR
@testable import Transport

class PaperProofCoordinatorDelegateSpy: PaperProofCoordinatorDelegate, OpenUrlProtocol, Dismissable {

	var invokedUserWishesToCancelPaperProofFlow = false
	var invokedUserWishesToCancelPaperProofFlowCount = 0

	func userWishesToCancelPaperProofFlow() {
		invokedUserWishesToCancelPaperProofFlow = true
		invokedUserWishesToCancelPaperProofFlowCount += 1
	}

	var invokedUserWishesMoreInformationOnNoInputToken = false
	var invokedUserWishesMoreInformationOnNoInputTokenCount = 0

	func userWishesMoreInformationOnNoInputToken() {
		invokedUserWishesMoreInformationOnNoInputToken = true
		invokedUserWishesMoreInformationOnNoInputTokenCount += 1
	}

	var invokedUserWishesMoreInformationOnWhichProofsCanBeUsed = false
	var invokedUserWishesMoreInformationOnWhichProofsCanBeUsedCount = 0

	func userWishesMoreInformationOnWhichProofsCanBeUsed() {
		invokedUserWishesMoreInformationOnWhichProofsCanBeUsed = true
		invokedUserWishesMoreInformationOnWhichProofsCanBeUsedCount += 1
	}

	var invokedUserWishesToScanCertificate = false
	var invokedUserWishesToScanCertificateCount = 0

	func userWishesToScanCertificate() {
		invokedUserWishesToScanCertificate = true
		invokedUserWishesToScanCertificateCount += 1
	}

	var invokedUserDidScanDCC = false
	var invokedUserDidScanDCCCount = 0
	var invokedUserDidScanDCCParameters: (message: String, Void)?
	var invokedUserDidScanDCCParametersList = [(message: String, Void)]()

	func userDidScanDCC(_ message: String) {
		invokedUserDidScanDCC = true
		invokedUserDidScanDCCCount += 1
		invokedUserDidScanDCCParameters = (message, ())
		invokedUserDidScanDCCParametersList.append((message, ()))
	}

	var invokedUserWishesToEnterToken = false
	var invokedUserWishesToEnterTokenCount = 0

	func userWishesToEnterToken() {
		invokedUserWishesToEnterToken = true
		invokedUserWishesToEnterTokenCount += 1
	}

	var invokedUserDidSubmitPaperProofToken = false
	var invokedUserDidSubmitPaperProofTokenCount = 0
	var invokedUserDidSubmitPaperProofTokenParameters: (token: String, Void)?
	var invokedUserDidSubmitPaperProofTokenParametersList = [(token: String, Void)]()

	func userDidSubmitPaperProofToken(token: String) {
		invokedUserDidSubmitPaperProofToken = true
		invokedUserDidSubmitPaperProofTokenCount += 1
		invokedUserDidSubmitPaperProofTokenParameters = (token, ())
		invokedUserDidSubmitPaperProofTokenParametersList.append((token, ()))
	}

	var invokedUserWishesToCreateACertificate = false
	var invokedUserWishesToCreateACertificateCount = 0

	func userWishesToCreateACertificate() {
		invokedUserWishesToCreateACertificate = true
		invokedUserWishesToCreateACertificateCount += 1
	}

	var invokedUserWantsToGoBackToDashboard = false
	var invokedUserWantsToGoBackToDashboardCount = 0

	func userWantsToGoBackToDashboard() {
		invokedUserWantsToGoBackToDashboard = true
		invokedUserWantsToGoBackToDashboardCount += 1
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

	var invokedDisplayErrorForPaperProofCheck = false
	var invokedDisplayErrorForPaperProofCheckCount = 0
	var invokedDisplayErrorForPaperProofCheckParameters: (content: Content, Void)?
	var invokedDisplayErrorForPaperProofCheckParametersList = [(content: Content, Void)]()

	func displayErrorForPaperProofCheck(content: Content) {
		invokedDisplayErrorForPaperProofCheck = true
		invokedDisplayErrorForPaperProofCheckCount += 1
		invokedDisplayErrorForPaperProofCheckParameters = (content, ())
		invokedDisplayErrorForPaperProofCheckParametersList.append((content, ()))
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()

	func openUrl(_ url: URL) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
