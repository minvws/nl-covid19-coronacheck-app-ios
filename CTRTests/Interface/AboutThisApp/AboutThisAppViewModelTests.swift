/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Clcore
import CoreData
import SnapshotTesting

class AboutThisAppViewModelTests: XCTestCase {
	
	private var sut: AboutThisAppViewModel!
	private var coordinatorSpy: AboutThisAppViewModelCoordinatorSpy!
	private var environmentSpies: EnvironmentSpies!
	private static var initialTimeZone: TimeZone?
	
	override class func setUp() {
		super.setUp()
		initialTimeZone = NSTimeZone.default
		NSTimeZone.default = TimeZone(abbreviation: "CEST")!
	}
	
	override class func tearDown() {
		super.tearDown()
		
		if let timeZone = initialTimeZone {
			NSTimeZone.default = timeZone
		}
	}
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = AboutThisAppViewModelCoordinatorSpy()
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder
		)
	}
	
	// MARK: Tests
	
	func test_initializationWithHolder() {
		
		// Given
		
		// When
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		
		// Then
		expect(self.sut.title) == L.holderAboutTitle()
		expect(self.sut.message) == L.holderAboutText()
		expect(self.sut.menu).to(haveCount(2))
		expect(self.sut.menu[0].key) == L.holderAboutReadmore()
		expect(self.sut.menu[0].value).to(haveCount(6))
		expect(self.sut.menu[0].value[0].identifier) == .privacyStatement
		expect(self.sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(self.sut.menu[0].value[2].identifier) == .colophon
		expect(self.sut.menu[0].value[3].identifier) == .storedEvents
		expect(self.sut.menu[0].value[4].identifier) == .reset
		expect(self.sut.menu[0].value[5].identifier) == .deeplink
		
		expect(self.sut.menu[1].value[0].identifier) == .useNoDisclosurePolicy
		expect(self.sut.menu[1].value[1].identifier) == .use1GDisclosurePolicy
		expect(self.sut.menu[1].value[2].identifier) == .use3GDisclosurePolicy
		expect(self.sut.menu[1].value[3].identifier) == .use1GAnd3GDisclosurePolicy
		expect(self.sut.menu[1].value[4].identifier) == .useConfigDisclosurePolicy
		
		expect(self.sut.appVersion.contains("testInitHolder")) == true
	}
	
	func test_initializationWithVerifier_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		
		// When
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)
		
		// Then
		expect(self.sut.title) == L.verifierAboutTitle()
		expect(self.sut.message) == L.verifierAboutText()
		expect(self.sut.menu).to(haveCount(2))
		expect(self.sut.menu[0].key) == L.verifierAboutReadmore()
		expect(self.sut.menu[0].value).to(haveCount(4))
		expect(self.sut.menu[0].value[0].identifier) == .privacyStatement
		expect(self.sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(self.sut.menu[0].value[2].identifier) == .colophon
		expect(self.sut.menu[0].value[3].identifier) == .reset
		
		expect(self.sut.menu[1].key) == L.verifier_about_this_app_law_enforcement()
		expect(self.sut.menu[1].value).to(haveCount(1))
		expect(self.sut.menu[1].value[0].identifier) == .scanlog
		expect(self.sut.appVersion.contains("testInitVerifier")) == true
	}
	
	func test_initializationWithVerifier_verificationPolicyDisabled() {
		
		// Given
		
		// When
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)
		
		// Then
		expect(self.sut.title) == L.verifierAboutTitle()
		expect(self.sut.message) == L.verifierAboutText()
		expect(self.sut.menu).to(haveCount(1))
		expect(self.sut.menu[0].key) == L.verifierAboutReadmore()
		expect(self.sut.menu[0].value).to(haveCount(4))
		expect(self.sut.menu[0].value[0].identifier) == .privacyStatement
		expect(self.sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(self.sut.menu[0].value[2].identifier) == .colophon
		expect(self.sut.menu[0].value[3].identifier) == .reset
		expect(self.sut.appVersion.contains("testInitVerifier")) == true
	}
	
	func test_menuOptionSelected_privacy() {
		
		// Given
		
		// When
		sut.menuOptionSelected(.privacyStatement)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlPrivacy()
	}
	
	func test_menuOptionSelected_terms() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)
		
		// When
		sut.menuOptionSelected(.privacyStatement)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierUrlPrivacy()
	}
	
	func test_menuOptionSelected_accessibility_forHolder() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		// When
		sut.menuOptionSelected(.accessibility)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlAccessibility()
	}
	
	func test_menuOptionSelected_colophon_forHolder() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		// When
		sut.menuOptionSelected(.colophon)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlColophon()
	}
	
	func test_menuOptionSelected_accessibility_forVerifier() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)
		
		// When
		sut.menuOptionSelected(.accessibility)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierUrlAccessibility()
	}
	
	func test_menuOptionSelected_colophon_forVerifier() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifie"),
			flavor: AppFlavor.verifier
		)
		// When
		sut.menuOptionSelected(.colophon)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlColophon()
	}
	
	func test_configVersionFooter_forVerifier() {
		
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "verifier"),
			flavor: AppFlavor.verifier
		)
		// When
		
		// Then
		expect(self.sut.configVersion) == "Configuratie hereisa, 15-07-2021 17:02"
	}
	
	func test_configVersionFooter_forHolder() {
		
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "holder"),
			flavor: AppFlavor.verifier
		)
		// When
		
		// Then
		expect(self.sut.configVersion) == "Configuratie hereisa, 15-07-2021 17:02"
	}
	
	func test_menuOptionSelected_clearData_forHolder() {

		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		// When
		sut.menuOptionSelected(.reset)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == false
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.holderCleardataAlertTitle()
		expect(self.sut.alert?.subTitle) == L.holderCleardataAlertSubtitle()
	}
	
	func test_menuOptionSelected_storedEvents_forHolder() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		// When
		sut.menuOptionSelected(.storedEvents)
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeStoredEvents) == true
	}
	
	func test_menuOptionSelected_deeplink_forHolder() {
		
		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		// When
		sut.menuOptionSelected(.deeplink)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString.contains("scanner-test")) == true
	}
	
	func test_resetData_holder() {

		// Given
		
		// When
		sut.wipePersistedData()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.onboardingManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.newFeaturesManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.scanLockManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.verificationPolicyManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.userSettingsSpy.invokedWipePersistedData) == true
		expect(self.coordinatorSpy.invokedRestart) == true
	}
	
	func test_resetData_verifier() {

		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)

		// When
		sut.wipePersistedData()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.onboardingManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.newFeaturesManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.scanLockManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.verificationPolicyManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.userSettingsSpy.invokedWipePersistedData) == true
		expect(self.coordinatorSpy.invokedRestart) == true
	}
	
	func test_menuOptionSelected_scanlog_forVerifier() {
		
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)
		// When
		sut.menuOptionSelected(.scanlog)
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToOpenScanLog) == true
	}
}

class AboutThisAppViewModelCoordinatorSpy: OpenUrlProtocol, Restartable, VerifierCoordinatorDelegate, HolderCoordinatorDelegate {

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

	var invokedRestart = false
	var invokedRestartCount = 0

	func restart() {
		invokedRestart = true
		invokedRestartCount += 1
	}

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

	var invokedUserWishesToOpenScanLog = false
	var invokedUserWishesToOpenScanLogCount = 0

	func userWishesToOpenScanLog() {
		invokedUserWishesToOpenScanLog = true
		invokedUserWishesToOpenScanLogCount += 1
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

	var invokedUserWishesToSeeEventDetails = false
	var invokedUserWishesToSeeEventDetailsCount = 0
	var invokedUserWishesToSeeEventDetailsParameters: (title: String, details: [EventDetails])?
	var invokedUserWishesToSeeEventDetailsParametersList = [(title: String, details: [EventDetails])]()

	func userWishesToSeeEventDetails(_ title: String, details: [EventDetails]) {
		invokedUserWishesToSeeEventDetails = true
		invokedUserWishesToSeeEventDetailsCount += 1
		invokedUserWishesToSeeEventDetailsParameters = (title, details)
		invokedUserWishesToSeeEventDetailsParametersList.append((title, details))
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

	var invokedUserWishesToViewQRs = false
	var invokedUserWishesToViewQRsCount = 0
	var invokedUserWishesToViewQRsParameters: (greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?)?
	var invokedUserWishesToViewQRsParametersList = [(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?)]()

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?) {
		invokedUserWishesToViewQRs = true
		invokedUserWishesToViewQRsCount += 1
		invokedUserWishesToViewQRsParameters = (greenCardObjectIDs, disclosurePolicy)
		invokedUserWishesToViewQRsParametersList.append((greenCardObjectIDs, disclosurePolicy))
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

	func displayError(content: Content, backAction: (() -> Void)?) {
		invokedDisplayError = true
		invokedDisplayErrorCount += 1
		invokedDisplayErrorParameters = (content, ())
		invokedDisplayErrorParametersList.append((content, ()))
		if shouldInvokeDisplayErrorBackAction {
			backAction?()
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

	var invokedUserWishesToSeeStoredEvents = false
	var invokedUserWishesToSeeStoredEventsCount = 0

	func userWishesToSeeStoredEvents() {
		invokedUserWishesToSeeStoredEvents = true
		invokedUserWishesToSeeStoredEventsCount += 1
	}
}
