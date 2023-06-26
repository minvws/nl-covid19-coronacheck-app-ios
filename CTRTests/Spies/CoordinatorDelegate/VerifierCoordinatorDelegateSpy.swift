/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Mobilecore

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

	var invokedNavigateToAboutThisApp = false
	var invokedNavigateToAboutThisAppCount = 0

	func navigateToAboutThisApp() {
		invokedNavigateToAboutThisApp = true
		invokedNavigateToAboutThisAppCount += 1
	}

	var invokedNavigateToVerifierWelcome = false
	var invokedNavigateToVerifierWelcomeCount = 0

	func navigateToVerifierWelcome() {
		invokedNavigateToVerifierWelcome = true
		invokedNavigateToVerifierWelcomeCount += 1
	}

	var invokedNavigateToOpenRiskLevelSettings = false
	var invokedNavigateToOpenRiskLevelSettingsCount = 0

	func navigateToOpenRiskLevelSettings() {
		invokedNavigateToOpenRiskLevelSettings = true
		invokedNavigateToOpenRiskLevelSettingsCount += 1
	}

	var invokedNavigateToScan = false
	var invokedNavigateToScanCount = 0

	func navigateToScan() {
		invokedNavigateToScan = true
		invokedNavigateToScanCount += 1
	}

	var invokedNavigateToScanInstruction = false
	var invokedNavigateToScanInstructionCount = 0
	var invokedNavigateToScanInstructionParameters: (allowSkipInstruction: Bool, Void)?
	var invokedNavigateToScanInstructionParametersList = [(allowSkipInstruction: Bool, Void)]()

	func navigateToScanInstruction(allowSkipInstruction: Bool) {
		invokedNavigateToScanInstruction = true
		invokedNavigateToScanInstructionCount += 1
		invokedNavigateToScanInstructionParameters = (allowSkipInstruction, ())
		invokedNavigateToScanInstructionParametersList.append((allowSkipInstruction, ()))
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

	var invokedUserWishesToOpenTheMenu = false
	var invokedUserWishesToOpenTheMenuCount = 0

	func userWishesToOpenTheMenu() {
		invokedUserWishesToOpenTheMenu = true
		invokedUserWishesToOpenTheMenuCount += 1
	}

	var invokedUserWishesToLaunchThirdPartyScannerApp = false
	var invokedUserWishesToLaunchThirdPartyScannerAppCount = 0

	func userWishesToLaunchThirdPartyScannerApp() {
		invokedUserWishesToLaunchThirdPartyScannerApp = true
		invokedUserWishesToLaunchThirdPartyScannerAppCount += 1
	}

	var invokedNavigateToCheckIdentity = false
	var invokedNavigateToCheckIdentityCount = 0
	var invokedNavigateToCheckIdentityParameters: (verificationDetails: MobilecoreVerificationDetails, Void)?
	var invokedNavigateToCheckIdentityParametersList = [(verificationDetails: MobilecoreVerificationDetails, Void)]()

	func navigateToCheckIdentity(_ verificationDetails: MobilecoreVerificationDetails) {
		invokedNavigateToCheckIdentity = true
		invokedNavigateToCheckIdentityCount += 1
		invokedNavigateToCheckIdentityParameters = (verificationDetails, ())
		invokedNavigateToCheckIdentityParametersList.append((verificationDetails, ()))
	}

	var invokedNavigateToVerifiedAccess = false
	var invokedNavigateToVerifiedAccessCount = 0
	var invokedNavigateToVerifiedAccessParameters: (verifiedAccess: VerifiedAccess, Void)?
	var invokedNavigateToVerifiedAccessParametersList = [(verifiedAccess: VerifiedAccess, Void)]()

	func navigateToVerifiedAccess(_ verifiedAccess: VerifiedAccess) {
		invokedNavigateToVerifiedAccess = true
		invokedNavigateToVerifiedAccessCount += 1
		invokedNavigateToVerifiedAccessParameters = (verifiedAccess, ())
		invokedNavigateToVerifiedAccessParametersList.append((verifiedAccess, ()))
	}

	var invokedNavigateToDeniedAccess = false
	var invokedNavigateToDeniedAccessCount = 0

	func navigateToDeniedAccess() {
		invokedNavigateToDeniedAccess = true
		invokedNavigateToDeniedAccessCount += 1
	}

	var invokedUserWishesToSetRiskLevel = false
	var invokedUserWishesToSetRiskLevelCount = 0
	var invokedUserWishesToSetRiskLevelParameters: (shouldSelectSetting: Bool, Void)?
	var invokedUserWishesToSetRiskLevelParametersList = [(shouldSelectSetting: Bool, Void)]()

	func userWishesToSetRiskLevel(shouldSelectSetting: Bool) {
		invokedUserWishesToSetRiskLevel = true
		invokedUserWishesToSetRiskLevelCount += 1
		invokedUserWishesToSetRiskLevelParameters = (shouldSelectSetting, ())
		invokedUserWishesToSetRiskLevelParametersList.append((shouldSelectSetting, ()))
	}

	var invokedUserWishesMoreInfoAboutDeniedQRScan = false
	var invokedUserWishesMoreInfoAboutDeniedQRScanCount = 0

	func userWishesMoreInfoAboutDeniedQRScan() {
		invokedUserWishesMoreInfoAboutDeniedQRScan = true
		invokedUserWishesMoreInfoAboutDeniedQRScanCount += 1
	}

	var invokedUserWishesToSeeHelpdesk = false
	var invokedUserWishesToSeeHelpdeskCount = 0

	func userWishesToSeeHelpdesk() {
		invokedUserWishesToSeeHelpdesk = true
		invokedUserWishesToSeeHelpdeskCount += 1
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}
