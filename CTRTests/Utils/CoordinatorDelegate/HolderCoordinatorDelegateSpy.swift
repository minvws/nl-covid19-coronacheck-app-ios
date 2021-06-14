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

	var invokedNavigateToAboutMakingAQR = false
	var invokedNavigateToAboutMakingAQRCount = 0

	func navigateToAboutMakingAQR() {
		invokedNavigateToAboutMakingAQR = true
		invokedNavigateToAboutMakingAQRCount += 1
	}

	var invokedNavigateToTokenScan = false
	var invokedNavigateToTokenScanCount = 0

	func navigateToTokenScan() {
		invokedNavigateToTokenScan = true
		invokedNavigateToTokenScanCount += 1
	}

	var invokedNavigateToListResults = false
	var invokedNavigateToListResultsCount = 0

	func navigateToListResults() {
		invokedNavigateToListResults = true
		invokedNavigateToListResultsCount += 1
	}

	var invokedNavigateToAboutTestResult = false
	var invokedNavigateToAboutTestResultCount = 0

	func navigateToAboutTestResult() {
		invokedNavigateToAboutTestResult = true
		invokedNavigateToAboutTestResultCount += 1
	}

	var invokedNavigateBackToStart = false
	var invokedNavigateBackToStartCount = 0

	func navigateBackToStart() {
		invokedNavigateBackToStart = true
		invokedNavigateBackToStartCount += 1
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

	var invokedUserWishesToMakeQRFromNegativeTest = false
	var invokedUserWishesToMakeQRFromNegativeTestCount = 0
	var invokedUserWishesToMakeQRFromNegativeTestParameters: (remoteTestEvent: RemoteTestEvent, Void)?
	var invokedUserWishesToMakeQRFromNegativeTestParametersList = [(remoteTestEvent: RemoteTestEvent, Void)]()

	func userWishesToMakeQRFromNegativeTest(_ remoteTestEvent: RemoteTestEvent) {
		invokedUserWishesToMakeQRFromNegativeTest = true
		invokedUserWishesToMakeQRFromNegativeTestCount += 1
		invokedUserWishesToMakeQRFromNegativeTestParameters = (remoteTestEvent, ())
		invokedUserWishesToMakeQRFromNegativeTestParametersList.append((remoteTestEvent, ()))
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

	var invokedUserWishesToChangeRegion = false
	var invokedUserWishesToChangeRegionCount = 0
	var invokedUserWishesToChangeRegionParameters: (currentRegion: QRCodeValidityRegion, Void)?
	var invokedUserWishesToChangeRegionParametersList = [(currentRegion: QRCodeValidityRegion, Void)]()
	var stubbedUserWishesToChangeRegionCompletionResult: (QRCodeValidityRegion, Void)?

	func userWishesToChangeRegion(currentRegion: QRCodeValidityRegion, completion: @escaping (QRCodeValidityRegion) -> Void) {
		invokedUserWishesToChangeRegion = true
		invokedUserWishesToChangeRegionCount += 1
		invokedUserWishesToChangeRegionParameters = (currentRegion, ())
		invokedUserWishesToChangeRegionParametersList.append((currentRegion, ()))
		if let result = stubbedUserWishesToChangeRegionCompletionResult {
			completion(result.0)
		}
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

	var invokedUserWishesToViewQR = false
	var invokedUserWishesToViewQRCount = 0
	var invokedUserWishesToViewQRParameters: (greenCardObjectID: NSManagedObjectID, Void)?
	var invokedUserWishesToViewQRParametersList = [(greenCardObjectID: NSManagedObjectID, Void)]()

	func userWishesToViewQR(greenCardObjectID: NSManagedObjectID) {
		invokedUserWishesToViewQR = true
		invokedUserWishesToViewQRCount += 1
		invokedUserWishesToViewQRParameters = (greenCardObjectID, ())
		invokedUserWishesToViewQRParametersList.append((greenCardObjectID, ()))
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
