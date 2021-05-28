/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class HolderCoordinatorDelegateSpy: HolderCoordinatorDelegate, Dismissable, OpenUrlProtocol {

	var invokedNavigateToShowQR = false
	var invokedNavigateToShowQRCount = 0

	func navigateToShowQR() {
		invokedNavigateToShowQR = true
		invokedNavigateToShowQRCount += 1
	}

	var invokedNavigateToAppointment = false
	var invokedNavigateToAppointmentCount = 0

	func navigateToAppointment() {
		invokedNavigateToAppointment = true
		invokedNavigateToAppointmentCount += 1
	}

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
	var invokedPresentInformationPageParameters: (title: String, body: String)?
	var invokedPresentInformationPageParametersList = [(title: String, body: String)]()

	func presentInformationPage(title: String, body: String) {
		invokedPresentInformationPage = true
		invokedPresentInformationPageCount += 1
		invokedPresentInformationPageParameters = (title, body)
		invokedPresentInformationPageParametersList.append((title, body))
	}

	var invokedUserWishesToMakeQRFromNegativeTest = false
	var invokedUserWishesToMakeQRFromNegativeTestCount = 0

	func userWishesToMakeQRFromNegativeTest() {
		invokedUserWishesToMakeQRFromNegativeTest = true
		invokedUserWishesToMakeQRFromNegativeTestCount += 1
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

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
