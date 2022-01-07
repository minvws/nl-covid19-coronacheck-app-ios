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
		expect(self.sut.menu).to(haveCount(1))
		expect(self.sut.menu[0].key) == L.holderAboutReadmore()
		expect(self.sut.menu[0].value).to(haveCount(5))
		expect(self.sut.menu[0].value[0].identifier) == .privacyStatement
		expect(self.sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(self.sut.menu[0].value[2].identifier) == .colophon
		expect(self.sut.menu[0].value[3].identifier) == .reset
		expect(self.sut.menu[0].value[4].identifier) == .deeplink
		expect(self.sut.appVersion.contains("testInitHolder")) == true
	}
	
	func test_initializationWithVerifier_verificationPolicyEnabled() {
		
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
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
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
		expect(self.environmentSpies.forcedInformationManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.scanLockManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.riskLevelManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.userSettingsSpy.invokedWipePersistedData) == true
		expect(self.coordinatorSpy.invokedRestart) == true
	}
	
	func test_resetData_verifier() {

		// Given
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
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
		expect(self.environmentSpies.forcedInformationManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.scanLockManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.riskLevelManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.userSettingsSpy.invokedWipePersistedData) == true
		expect(self.coordinatorSpy.invokedRestart) == true
	}
	
	func test_menuOptionSelected_scanlog_forVerifier() {
		
		sut = AboutThisAppViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifie"),
			flavor: AppFlavor.verifier
		)
		// When
		sut.menuOptionSelected(.scanlog)
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToOpenScanLog) == true
	}
}

class AboutThisAppViewModelCoordinatorSpy: OpenUrlProtocol, Restartable, VerifierCoordinatorDelegate {

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

	var invokedNavigateToScanNextInstruction = false
	var invokedNavigateToScanNextInstructionCount = 0
	var invokedNavigateToScanNextInstructionParameters: (scanNext: ScanNext, Void)?
	var invokedNavigateToScanNextInstructionParametersList = [(scanNext: ScanNext, Void)]()

	func navigateToScanNextInstruction(_ scanNext: ScanNext) {
		invokedNavigateToScanNextInstruction = true
		invokedNavigateToScanNextInstructionCount += 1
		invokedNavigateToScanNextInstructionParameters = (scanNext, ())
		invokedNavigateToScanNextInstructionParametersList.append((scanNext, ()))
	}
}
