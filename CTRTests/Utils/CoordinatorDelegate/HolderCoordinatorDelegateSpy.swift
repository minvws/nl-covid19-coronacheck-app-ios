/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoreData
import XCTest
@testable import CTR

class HolderCoordinatorDelegateSpy: HolderCoordinatorDelegate, Dismissable, OpenUrlProtocol {

	var invokedNavigateBackToStart = false
	var invokedNavigateBackToStartCount = 0

	func navigateBackToStart() {
		invokedNavigateBackToStart = true
		invokedNavigateBackToStartCount += 1
	}

	var invokedPresentInformationPage = false
	var invokedPresentInformationPageCount = 0
	var invokedPresentInformationPageParameters: (title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool)?
	var invokedPresentInformationPageParametersList = [(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool)]()

	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool) {
		invokedPresentInformationPage = true
		invokedPresentInformationPageCount += 1
		invokedPresentInformationPageParameters = (title, body, hideBodyForScreenCapture, openURLsInApp)
		invokedPresentInformationPageParametersList.append((title, body, hideBodyForScreenCapture, openURLsInApp))
	}

	var invokedPresentDCCQRDetails = false
	var invokedPresentDCCQRDetailsCount = 0
	var invokedPresentDCCQRDetailsParameters: (title: String, description: String, details: [DCCQRDetails], dateInformation: String)?
	var invokedPresentDCCQRDetailsParametersList = [(title: String, description: String, details: [DCCQRDetails], dateInformation: String)]()

	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String) {
		invokedPresentDCCQRDetails = true
		invokedPresentDCCQRDetailsCount += 1
		invokedPresentDCCQRDetailsParameters = (title, description, details, dateInformation)
		invokedPresentDCCQRDetailsParametersList.append((title, description, details, dateInformation))
	}

	var invokedUserWishesToMakeQRFromRemoteEvent = false
	var invokedUserWishesToMakeQRFromRemoteEventCount = 0
	var invokedUserWishesToMakeQRFromRemoteEventParameters: (remoteEvent: RemoteEvent, originalMode: EventMode)?
	var invokedUserWishesToMakeQRFromRemoteEventParametersList = [(remoteEvent: RemoteEvent, originalMode: EventMode)]()

	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode) {
		invokedUserWishesToMakeQRFromRemoteEvent = true
		invokedUserWishesToMakeQRFromRemoteEventCount += 1
		invokedUserWishesToMakeQRFromRemoteEventParameters = (remoteEvent, originalMode)
		invokedUserWishesToMakeQRFromRemoteEventParametersList.append((remoteEvent, originalMode))
	}

	var invokedUserWishesToCreateAQR = false
	var invokedUserWishesToCreateAQRCount = 0

	func userWishesToCreateAQR() {
		invokedUserWishesToCreateAQR = true
		invokedUserWishesToCreateAQRCount += 1
	}

	var invokedUserWishesToCreateANegativeTestQR = false
	var invokedUserWishesToCreateANegativeTestQRCount = 0

	func userWishesToCreateANegativeTestQR() {
		invokedUserWishesToCreateANegativeTestQR = true
		invokedUserWishesToCreateANegativeTestQRCount += 1
	}

	var invokedUserWishesToCreateAVisitorPass = false
	var invokedUserWishesToCreateAVisitorPassCount = 0

	func userWishesToCreateAVisitorPass() {
		invokedUserWishesToCreateAVisitorPass = true
		invokedUserWishesToCreateAVisitorPassCount += 1
	}

	var invokedUserWishesToChooseTestLocation = false
	var invokedUserWishesToChooseTestLocationCount = 0

	func userWishesToChooseTestLocation() {
		invokedUserWishesToChooseTestLocation = true
		invokedUserWishesToChooseTestLocationCount += 1
	}

	var invokedUserHasNotBeenTested = false
	var invokedUserHasNotBeenTestedCount = 0

	func userHasNotBeenTested() {
		invokedUserHasNotBeenTested = true
		invokedUserHasNotBeenTestedCount += 1
	}

	var invokedUserWishesToCreateANegativeTestQRFromGGD = false
	var invokedUserWishesToCreateANegativeTestQRFromGGDCount = 0

	func userWishesToCreateANegativeTestQRFromGGD() {
		invokedUserWishesToCreateANegativeTestQRFromGGD = true
		invokedUserWishesToCreateANegativeTestQRFromGGDCount += 1
	}

	var invokedUserWishesToCreateAVaccinationQR = false
	var invokedUserWishesToCreateAVaccinationQRCount = 0

	func userWishesToCreateAVaccinationQR() {
		invokedUserWishesToCreateAVaccinationQR = true
		invokedUserWishesToCreateAVaccinationQRCount += 1
	}

	var invokedUserWishesToCreateARecoveryQR = false
	var invokedUserWishesToCreateARecoveryQRCount = 0

	func userWishesToCreateARecoveryQR() {
		invokedUserWishesToCreateARecoveryQR = true
		invokedUserWishesToCreateARecoveryQRCount += 1
	}

	var invokedUserWishesToFetchPositiveTests = false
	var invokedUserWishesToFetchPositiveTestsCount = 0

	func userWishesToFetchPositiveTests() {
		invokedUserWishesToFetchPositiveTests = true
		invokedUserWishesToFetchPositiveTestsCount += 1
	}

	var invokedUserDidScanRequestToken = false
	var invokedUserDidScanRequestTokenCount = 0
	var invokedUserDidScanRequestTokenParameters: (requestToken: RequestToken, Void)?
	var invokedUserDidScanRequestTokenParametersList = [(requestToken: RequestToken, Void)]()

	func userDidScanRequestToken(requestToken: RequestToken) {
		invokedUserDidScanRequestToken = true
		invokedUserDidScanRequestTokenCount += 1
		invokedUserDidScanRequestTokenParameters = (requestToken, ())
		invokedUserDidScanRequestTokenParametersList.append((requestToken, ()))
	}

	var invokedUserWishesMoreInfoAboutUnavailableQR = false
	var invokedUserWishesMoreInfoAboutUnavailableQRCount = 0
	var invokedUserWishesMoreInfoAboutUnavailableQRParameters: (originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion)?
	var invokedUserWishesMoreInfoAboutUnavailableQRParametersList = [(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion)]()

	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) {
		invokedUserWishesMoreInfoAboutUnavailableQR = true
		invokedUserWishesMoreInfoAboutUnavailableQRCount += 1
		invokedUserWishesMoreInfoAboutUnavailableQRParameters = (originType, currentRegion, availableRegion)
		invokedUserWishesMoreInfoAboutUnavailableQRParametersList.append((originType, currentRegion, availableRegion))
	}

	var invokedUserWishesMoreInfoAboutClockDeviation = false
	var invokedUserWishesMoreInfoAboutClockDeviationCount = 0

	func userWishesMoreInfoAboutClockDeviation() {
		invokedUserWishesMoreInfoAboutClockDeviation = true
		invokedUserWishesMoreInfoAboutClockDeviationCount += 1
	}

	var invokedUserWishesMoreInfoAboutCompletingVaccinationAssessment = false
	var invokedUserWishesMoreInfoAboutCompletingVaccinationAssessmentCount = 0

	func userWishesMoreInfoAboutCompletingVaccinationAssessment() {
		invokedUserWishesMoreInfoAboutCompletingVaccinationAssessment = true
		invokedUserWishesMoreInfoAboutCompletingVaccinationAssessmentCount += 1
	}

	var invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL = false
	var invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNLCount = 0

	func userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL() {
		invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL = true
		invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNLCount += 1
	}

	var invokedUserWishesMoreInfoAboutTestOnlyValidFor3G = false
	var invokedUserWishesMoreInfoAboutTestOnlyValidFor3GCount = 0

	func userWishesMoreInfoAboutTestOnlyValidFor3G() {
		invokedUserWishesMoreInfoAboutTestOnlyValidFor3G = true
		invokedUserWishesMoreInfoAboutTestOnlyValidFor3GCount += 1
	}

	var invokedUserWishesMoreInfoAboutOutdatedConfig = false
	var invokedUserWishesMoreInfoAboutOutdatedConfigCount = 0
	var invokedUserWishesMoreInfoAboutOutdatedConfigParameters: (validUntil: String, Void)?
	var invokedUserWishesMoreInfoAboutOutdatedConfigParametersList = [(validUntil: String, Void)]()

	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String) {
		invokedUserWishesMoreInfoAboutOutdatedConfig = true
		invokedUserWishesMoreInfoAboutOutdatedConfigCount += 1
		invokedUserWishesMoreInfoAboutOutdatedConfigParameters = (validUntil, ())
		invokedUserWishesMoreInfoAboutOutdatedConfigParametersList.append((validUntil, ()))
	}

	var invokedUserWishesMoreInfoAboutIncompleteDutchVaccination = false
	var invokedUserWishesMoreInfoAboutIncompleteDutchVaccinationCount = 0

	func userWishesMoreInfoAboutIncompleteDutchVaccination() {
		invokedUserWishesMoreInfoAboutIncompleteDutchVaccination = true
		invokedUserWishesMoreInfoAboutIncompleteDutchVaccinationCount += 1
	}

	var invokedUserWishesMoreInfoAboutExpiredDomesticVaccination = false
	var invokedUserWishesMoreInfoAboutExpiredDomesticVaccinationCount = 0

	func userWishesMoreInfoAboutExpiredDomesticVaccination() {
		invokedUserWishesMoreInfoAboutExpiredDomesticVaccination = true
		invokedUserWishesMoreInfoAboutExpiredDomesticVaccinationCount += 1
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

	var invokedUserWishesToViewQRs = false
	var invokedUserWishesToViewQRsCount = 0
	var invokedUserWishesToViewQRsParameters: (greenCardObjectIDs: [NSManagedObjectID], Void)?
	var invokedUserWishesToViewQRsParametersList = [(greenCardObjectIDs: [NSManagedObjectID], Void)]()

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID]) {
		invokedUserWishesToViewQRs = true
		invokedUserWishesToViewQRsCount += 1
		invokedUserWishesToViewQRsParameters = (greenCardObjectIDs, ())
		invokedUserWishesToViewQRsParametersList.append((greenCardObjectIDs, ()))
	}

	var invokedUserWishesToLaunchThirdPartyTicketApp = false
	var invokedUserWishesToLaunchThirdPartyTicketAppCount = 0

	func userWishesToLaunchThirdPartyTicketApp() {
		invokedUserWishesToLaunchThirdPartyTicketApp = true
		invokedUserWishesToLaunchThirdPartyTicketAppCount += 1
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

	var invokedUserWishesMoreInfoAboutNoTestToken = false
	var invokedUserWishesMoreInfoAboutNoTestTokenCount = 0

	func userWishesMoreInfoAboutNoTestToken() {
		invokedUserWishesMoreInfoAboutNoTestToken = true
		invokedUserWishesMoreInfoAboutNoTestTokenCount += 1
	}

	var invokedUserWishesMoreInfoAboutNoVisitorPassToken = false
	var invokedUserWishesMoreInfoAboutNoVisitorPassTokenCount = 0

	func userWishesMoreInfoAboutNoVisitorPassToken() {
		invokedUserWishesMoreInfoAboutNoVisitorPassToken = true
		invokedUserWishesMoreInfoAboutNoVisitorPassTokenCount += 1
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
