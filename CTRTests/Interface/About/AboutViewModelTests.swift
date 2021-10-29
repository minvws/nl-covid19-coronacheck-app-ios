/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class AboutViewModelTests: XCTestCase {

	private var sut: AboutViewModel!
	private var coordinatorSpy: AboutViewModelCoordinatorSpy!
	private var userSettingsSpy: UserSettingsSpy!
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

		coordinatorSpy = AboutViewModelCoordinatorSpy()
		userSettingsSpy = UserSettingsSpy()
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	// MARK: Tests

	func test_initializationWithHolder() {

		// Given

		// When
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.sut.title) == L.holderAboutTitle()
		expect(self.sut.message) == L.holderAboutText()
		expect(self.sut.listHeader) == L.holderAboutReadmore()
		expect(self.sut.menu).to(haveCount(5))
		expect(self.sut.menu[0].identifier) == .privacyStatement
		expect(self.sut.menu[1].identifier) == AboutMenuIdentifier.accessibility
		expect(self.sut.menu[2].identifier) == .colophon
		expect(self.sut.menu[3].identifier) == .reset
		expect(self.sut.menu[4].identifier) == .deeplink
		expect(self.sut.appVersion.contains("testInitHolder")) == true
	}

	func test_initializationWithVerifier() {

		// Given

		// When
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.sut.title) == L.verifierAboutTitle()
		expect(self.sut.message) == L.verifierAboutText()
		expect(self.sut.listHeader) == L.verifierAboutReadmore()
		expect(self.sut.menu).to(haveCount(3))
		expect(self.sut.menu.first?.identifier) == .terms
		expect(self.sut.menu[1].identifier) == AboutMenuIdentifier.accessibility
		expect(self.sut.menu.last?.identifier) == .colophon
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

		// When
		sut.menuOptionSelected(.terms)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierUrlPrivacy()
	}

	func test_menuOptionSelected_accessibility_forHolder() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)
		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlAccessibility()
	}

	func test_menuOptionSelected_colophon_forHolder() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)
		// When
		sut.menuOptionSelected(.colophon)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlColophon()
	}

	func test_menuOptionSelected_accessibility_forVerifier() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)

		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierUrlAccessibility()
	}

	func test_menuOptionSelected_colophon_forVerifier() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifie"),
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)
		// When
		sut.menuOptionSelected(.colophon)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlColophon()
	}

	func test_configVersionFooter_forVerifier() {

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "verifier"),
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)
		// When

		// Then
		expect(self.sut.configVersion) == "Configuratie hereisa, 15-07-2021 17:02"
	}

	func test_configVersionFooter_forHolder() {

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "holder"),
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)
		// When

		// Then
		expect(self.sut.configVersion) == "Configuratie hereisa, 15-07-2021 17:02"
	}

	func test_menuOptionSelected_clearData_forHolder() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
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
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)
		// When
		sut.menuOptionSelected(.deeplink)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString.contains("scanner-test")) == true
	}

	func test_resetData() {

		// Given
		let walletSpy = WalletManagerSpy()
		Services.use(walletSpy)
		let remoteConfigSpy = RemoteConfigManagingSpy(now: { now }, userSettings: UserSettingsSpy(), networkManager: NetworkSpy())
		remoteConfigSpy.stubbedStoredConfiguration = .default
		Services.use(remoteConfigSpy)
		let cryptoLibUtilitySpy = CryptoLibUtilitySpy(fileStorage: FileStorage(), flavor: AppFlavor.flavor)
		Services.use(cryptoLibUtilitySpy)
		let onboardingSpy = OnboardingManagerSpy()
		Services.use(onboardingSpy)
		let forcedInfoSpy = ForcedInformationManagerSpy()
		Services.use(forcedInfoSpy)

		// When
		sut.resetDataAndRestart()

		// Then
		expect(walletSpy.invokedRemoveExistingGreenCards) == true
		expect(walletSpy.invokedRemoveExistingEventGroups) == true
		expect(remoteConfigSpy.invokedReset) == true
		expect(cryptoLibUtilitySpy.invokedReset) == true
		expect(onboardingSpy.invokedReset) == true
		expect(forcedInfoSpy.invokedReset) == true
		expect(self.userSettingsSpy.invokedReset) == true
		expect(self.coordinatorSpy.invokedRestart) == true
	}
}

class AboutViewModelCoordinatorSpy: OpenUrlProtocol, Restartable {

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
}
