/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class HolderCoordinatorDelegateSpy: HolderCoordinatorDelegate, Dismissable, OpenUrlProtocol {

	var navigateToAppointmentCalled = false
	var navigateToEnlargedQRCalled = false
	var navigateToChooseProviderCalled = false
	var navigateToTokenScanCalled = false
	var navigateToTokenEntryCalled = false
	var navigateToListResultsCalled = false
	var navigateToAboutTestResultCalled = false
	var navigateBackToStartCalled = false
	var presentInformationPageCalled = false
	var dismissCalled = false
	var openUrlCalled = false
	var startVaccinationEventFlowCalled = false

	func navigateToEnlargedQR() {

		navigateToEnlargedQRCalled = true
	}

	func navigateToAppointment() {

		navigateToAppointmentCalled = true
	}

	func navigateToChooseProvider() {

		navigateToChooseProviderCalled = true
	}

	func navigateToTokenScan() {

		navigateToTokenScanCalled = true
	}

	func navigateToTokenEntry(_ token: RequestToken?) {

		navigateToTokenEntryCalled = true
	}

	func navigateToListResults() {

		navigateToListResultsCalled = true
	}

	func navigateToAboutTestResult() {

		navigateToAboutTestResultCalled = true
	}

	func navigateBackToStart() {

		navigateBackToStartCalled = true
	}

	func presentInformationPage(title: String, body: String, showBottomCloseButton: Bool) {

		presentInformationPageCalled = true
	}

	func dismiss() {

		dismissCalled = true
	}

	func openUrl(_ url: URL, inApp: Bool) {

		openUrlCalled = true
	}

	func startVaccinationEventFlow() {

		startVaccinationEventFlowCalled = true
	}
}
