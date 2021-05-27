/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class HolderCoordinatorDelegateSpy: HolderCoordinatorDelegate, Dismissable, OpenUrlProtocol {

	var invokedNavigateToEnlargedQR = false
	var invokedNavigateToEnlargedQRCount = 0

	func navigateToEnlargedQR() {
		invokedNavigateToEnlargedQR = true
		invokedNavigateToEnlargedQRCount += 1
	}

	var invokedNavigateToAppointment = false
	var invokedNavigateToAppointmentCount = 0

	func navigateToAppointment() {
		invokedNavigateToAppointment = true
		invokedNavigateToAppointmentCount += 1
	}

	var invokedNavigateToTokenScan = false
	var invokedNavigateToTokenScanCount = 0

	func navigateToTokenScan() {
		invokedNavigateToTokenScan = true
		invokedNavigateToTokenScanCount += 1
	}

	var invokedNavigateToTokenEntry = false
	var invokedNavigateToTokenEntryCount = 0
	var invokedNavigateToTokenEntryParameters: (token: RequestToken?, Void)?
	var invokedNavigateToTokenEntryParametersList = [(token: RequestToken?, Void)]()

	func navigateToTokenEntry(_ token: RequestToken?) {
		invokedNavigateToTokenEntry = true
		invokedNavigateToTokenEntryCount += 1
		invokedNavigateToTokenEntryParameters = (token, ())
		invokedNavigateToTokenEntryParametersList.append((token, ()))
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
	var invokedPresentInformationPageParameters: (title: String, body: String, showBottomCloseButton: Bool)?
	var invokedPresentInformationPageParametersList = [(title: String, body: String, showBottomCloseButton: Bool)]()

	func presentInformationPage(title: String, body: String, showBottomCloseButton: Bool) {
		invokedPresentInformationPage = true
		invokedPresentInformationPageCount += 1
		invokedPresentInformationPageParameters = (title, body, showBottomCloseButton)
		invokedPresentInformationPageParametersList.append((title, body, showBottomCloseButton))
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
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
