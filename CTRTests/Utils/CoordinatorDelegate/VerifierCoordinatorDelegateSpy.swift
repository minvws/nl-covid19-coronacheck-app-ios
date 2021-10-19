/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Clcore

class VerifierCoordinatorDelegateSpy: VerifierCoordinatorDelegate, OpenUrlProtocol, Dismissable {

	var invokedDidFinish = false
	var invokedDidFinishCount = 0
	var invokedDidFinishParameters: (result: VerifierStartResult, Void)?
	var invokedDidFinishParametersList = [(result: VerifierStartResult, Void)]()

	func didFinish(_ result: VerifierStartResult) {
		invokedDidFinish = true
		invokedDidFinishCount += 1
		invokedDidFinishParameters = (result, ())
		invokedDidFinishParametersList.append((result, ()))
	}

	var invokedNavigateToVerifierWelcome = false
	var invokedNavigateToVerifierWelcomeCount = 0

	func navigateToVerifierWelcome() {
		invokedNavigateToVerifierWelcome = true
		invokedNavigateToVerifierWelcomeCount += 1
	}

	var invokedNavigateToScan = false
	var invokedNavigateToScanCount = 0

	func navigateToScan() {
		invokedNavigateToScan = true
		invokedNavigateToScanCount += 1
	}

	var invokedNavigateToScanInstruction = false
	var invokedNavigateToScanInstructionCount = 0

	func navigateToScanInstruction() {
		invokedNavigateToScanInstruction = true
		invokedNavigateToScanInstructionCount += 1
	}

	var invokedNavigateToScanResult = false
	var invokedNavigateToScanResultCount = 0
	var invokedNavigateToScanResultParameters: (verificationResult: MobilecoreVerificationResult, Void)?
	var invokedNavigateToScanResultParametersList = [(verificationResult: MobilecoreVerificationResult, Void)]()

	func navigateToScanResult(_ verificationResult: MobilecoreVerificationResult) {
		invokedNavigateToScanResult = true
		invokedNavigateToScanResultCount += 1
		invokedNavigateToScanResultParameters = (verificationResult, ())
		invokedNavigateToScanResultParametersList.append((verificationResult, ()))
	}

	var invokedDisplayContent = false
	var invokedDisplayContentCount = 0
	var invokedDisplayContentParameters: (title: String, content: [DisplayContent])?
	var invokedDisplayContentParametersList = [(title: String, content: [DisplayContent])]()

	func displayContent(title: String, content: [DisplayContent]) {
		invokedDisplayContent = true
		invokedDisplayContentCount += 1
		invokedDisplayContentParameters = (title, content)
		invokedDisplayContentParametersList.append((title, content))
	}

	var invokedUserWishesMoreInfoAboutClockDeviation = false
	var invokedUserWishesMoreInfoAboutClockDeviationCount = 0

	func userWishesMoreInfoAboutClockDeviation() {
		invokedUserWishesMoreInfoAboutClockDeviation = true
		invokedUserWishesMoreInfoAboutClockDeviationCount += 1
	}

	var invokedNavigateToVerifiedInfo = false
	var invokedNavigateToVerifiedInfoCount = 0

	func navigateToVerifiedInfo() {
		invokedNavigateToVerifiedInfo = true
		invokedNavigateToVerifiedInfoCount += 1
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
