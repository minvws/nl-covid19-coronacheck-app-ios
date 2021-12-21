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

	var invokedUserWishesToMakeQRFromNegativeTest = false
	var invokedUserWishesToMakeQRFromNegativeTestCount = 0
	var invokedUserWishesToMakeQRFromNegativeTestParameters: (remoteEvent: RemoteEvent, Void)?
	var invokedUserWishesToMakeQRFromNegativeTestParametersList = [(remoteEvent: RemoteEvent, Void)]()

	func userWishesToMakeQRFromNegativeTest(_ remoteEvent: RemoteEvent) {
		invokedUserWishesToMakeQRFromNegativeTest = true
		invokedUserWishesToMakeQRFromNegativeTestCount += 1
		invokedUserWishesToMakeQRFromNegativeTestParameters = (remoteEvent, ())
		invokedUserWishesToMakeQRFromNegativeTestParametersList.append((remoteEvent, ()))
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

	var invokedUserWishesToChooseLocation = false
	var invokedUserWishesToChooseLocationCount = 0

	func userWishesToChooseLocation() {
		invokedUserWishesToChooseLocation = true
		invokedUserWishesToChooseLocationCount += 1
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

	var invokedUserWishesMoreInfoAboutTestOnlyValidFor3G = false
	var invokedUserWishesMoreInfoAboutTestOnlyValidFor3GCount = 0

	func userWishesMoreInfoAboutTestOnlyValidFor3G() {
		invokedUserWishesMoreInfoAboutTestOnlyValidFor3G = true
		invokedUserWishesMoreInfoAboutTestOnlyValidFor3GCount += 1
	}

	var invokedUserWishesMoreInfoAboutUpgradingEUVaccinations = false
	var invokedUserWishesMoreInfoAboutUpgradingEUVaccinationsCount = 0

	func userWishesMoreInfoAboutUpgradingEUVaccinations() {
		invokedUserWishesMoreInfoAboutUpgradingEUVaccinations = true
		invokedUserWishesMoreInfoAboutUpgradingEUVaccinationsCount += 1
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

	var invokedUserWishesMoreInfoAboutRecoveryValidityExtension = false
	var invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCount = 0

	func userWishesMoreInfoAboutRecoveryValidityExtension() {
		invokedUserWishesMoreInfoAboutRecoveryValidityExtension = true
		invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCount += 1
	}

	var invokedUserWishesMoreInfoAboutRecoveryValidityReinstation = false
	var invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCount = 0

	func userWishesMoreInfoAboutRecoveryValidityReinstation() {
		invokedUserWishesMoreInfoAboutRecoveryValidityReinstation = true
		invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCount += 1
	}

	var invokedUserWishesMoreInfoAboutIncompleteDutchVaccination = false
	var invokedUserWishesMoreInfoAboutIncompleteDutchVaccinationCount = 0

	func userWishesMoreInfoAboutIncompleteDutchVaccination() {
		invokedUserWishesMoreInfoAboutIncompleteDutchVaccination = true
		invokedUserWishesMoreInfoAboutIncompleteDutchVaccinationCount += 1
	}

	var invokedUserWishesMoreInfoAboutMultipleDCCUpgradeCompleted = false
	var invokedUserWishesMoreInfoAboutMultipleDCCUpgradeCompletedCount = 0

	func userWishesMoreInfoAboutMultipleDCCUpgradeCompleted() {
		invokedUserWishesMoreInfoAboutMultipleDCCUpgradeCompleted = true
		invokedUserWishesMoreInfoAboutMultipleDCCUpgradeCompletedCount += 1
	}

	var invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCompleted = false
	var invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCompletedCount = 0

	func userWishesMoreInfoAboutRecoveryValidityExtensionCompleted() {
		invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCompleted = true
		invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCompletedCount += 1
	}

	var invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCompleted = false
	var invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCompletedCount = 0

	func userWishesMoreInfoAboutRecoveryValidityReinstationCompleted() {
		invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCompleted = true
		invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCompletedCount += 1
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

	var invokedMigrateEUVaccinationDidComplete = false
	var invokedMigrateEUVaccinationDidCompleteCount = 0

	func migrateEUVaccinationDidComplete() {
		invokedMigrateEUVaccinationDidComplete = true
		invokedMigrateEUVaccinationDidCompleteCount += 1
	}

	var invokedExtendRecoveryValidityDidComplete = false
	var invokedExtendRecoveryValidityDidCompleteCount = 0

	func extendRecoveryValidityDidComplete() {
		invokedExtendRecoveryValidityDidComplete = true
		invokedExtendRecoveryValidityDidCompleteCount += 1
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
