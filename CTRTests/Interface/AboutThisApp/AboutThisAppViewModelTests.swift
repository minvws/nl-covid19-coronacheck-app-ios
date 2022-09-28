/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import Clcore
import CoreData
import SnapshotTesting

class AboutThisAppViewModelTests: XCTestCase {
	
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
	}
	
	// MARK: Tests
	
	func test_initializationWithHolder() {
		
		// Given
		
		// When
		var outcomes = [AboutThisAppViewModel.Outcome]()
		
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		) { outcome in
			outcomes.append(outcome)
		}
		
		// Then
		expect(sut.title) == L.holderAboutTitle()
		expect(sut.message) == L.holderAboutText()
		expect(sut.menu).to(haveCount(2))
		expect(sut.menu[0].key) == L.holderAboutReadmore()
		expect(sut.menu[0].value).to(haveCount(6))
		expect(sut.menu[0].value[0].identifier) == .privacyStatement
		expect(sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(sut.menu[0].value[2].identifier) == .colophon
		expect(sut.menu[0].value[3].identifier) == .storedEvents
		expect(sut.menu[0].value[4].identifier) == .reset
		expect(sut.menu[0].value[5].identifier) == .deeplink
		
		expect(sut.menu[1].value[0].identifier) == .useNoDisclosurePolicy
		expect(sut.menu[1].value[1].identifier) == .use1GDisclosurePolicy
		expect(sut.menu[1].value[2].identifier) == .use3GDisclosurePolicy
		expect(sut.menu[1].value[3].identifier) == .use1GAnd3GDisclosurePolicy
		expect(sut.menu[1].value[4].identifier) == .useConfigDisclosurePolicy
		
		expect(sut.appVersion.contains("testInitHolder")) == true
		expect(outcomes).to(beEmpty())
	}
	
	func test_initializationWithVerifier_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		
		// When
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		) { outcome in
			outcomes.append(outcome)
		}
		
		// Then
		expect(sut.title) == L.verifierAboutTitle()
		expect(sut.message) == L.verifierAboutText()
		expect(sut.menu).to(haveCount(2))
		expect(sut.menu[0].key) == L.verifierAboutReadmore()
		expect(sut.menu[0].value).to(haveCount(4))
		expect(sut.menu[0].value[0].identifier) == .privacyStatement
		expect(sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(sut.menu[0].value[2].identifier) == .colophon
		expect(sut.menu[0].value[3].identifier) == .reset
		
		expect(sut.menu[1].key) == L.verifier_about_this_app_law_enforcement()
		expect(sut.menu[1].value).to(haveCount(1))
		expect(sut.menu[1].value[0].identifier) == .scanlog
		expect(sut.appVersion.contains("testInitVerifier")) == true
		expect(outcomes).to(beEmpty())
	}
	
	func test_initializationWithVerifier_verificationPolicyDisabled() {
		
		// Given
		
		// When
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		) { outcome in
			outcomes.append(outcome)
		}
		
		// Then
		expect(sut.title) == L.verifierAboutTitle()
		expect(sut.message) == L.verifierAboutText()
		expect(sut.menu).to(haveCount(1))
		expect(sut.menu[0].key) == L.verifierAboutReadmore()
		expect(sut.menu[0].value).to(haveCount(4))
		expect(sut.menu[0].value[0].identifier) == .privacyStatement
		expect(sut.menu[0].value[1].identifier) == AboutThisAppMenuIdentifier.accessibility
		expect(sut.menu[0].value[2].identifier) == .colophon
		expect(sut.menu[0].value[3].identifier) == .reset
		expect(sut.appVersion.contains("testInitVerifier")) == true
		expect(outcomes).to(beEmpty())
	}
	
	func test_menuOptionSelected_privacy() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes += [outcome]
			}
		)

		// When
		sut.menuOptionSelected(.privacyStatement)

		// Then
		let url = URL(string: L.holderUrlPrivacy())!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == AboutThisAppViewModel.Outcome.openURL(url, inApp: true)
	}
	
	func test_menuOptionSelected_terms() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)

		// When
		sut.menuOptionSelected(.colophon)
		
		// Then
		let url = URL(string: L.holderUrlColophon())!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == AboutThisAppViewModel.Outcome.openURL(url, inApp: true)
	}
	
	func test_menuOptionSelected_accessibility_forHolder() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)

		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		let url = URL(string: L.holderUrlAccessibility())!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == AboutThisAppViewModel.Outcome.openURL(url, inApp: true)
	}

	func test_menuOptionSelected_colophon_forHolder() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)
		// When
		sut.menuOptionSelected(.colophon)

		// Then
		let url = URL(string: L.holderUrlColophon())!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == AboutThisAppViewModel.Outcome.openURL(url, inApp: true)
	}

	func test_menuOptionSelected_accessibility_forVerifier() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)

		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		let url = URL(string: L.verifierUrlAccessibility())!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == AboutThisAppViewModel.Outcome.openURL(url, inApp: true)
	}

	func test_menuOptionSelected_colophon_forVerifier() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifie"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)
		// When
		sut.menuOptionSelected(.colophon)

		// Then
		let url = URL(string: L.holderUrlColophon())!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == AboutThisAppViewModel.Outcome.openURL(url, inApp: true)
	}
	
	func test_configVersionFooter_forVerifier() {
		
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		
		// Given
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "verifier"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { _ in }
		)
		// When
		
		// Then
		expect(sut.configVersion) == "Configuratie hereisa, 15-07-2021 17:02"
	}
	
	func test_configVersionFooter_forHolder() {
		
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		
		// Given
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "holder"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { _ in }
		)
		// When
		
		// Then
		expect(sut.configVersion) == "Configuratie hereisa, 15-07-2021 17:02"
	}
	
	func test_menuOptionSelected_clearData_forHolder() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)
		// When
		sut.menuOptionSelected(.reset)

		// Then
		expect(sut.alert) != nil
		expect(sut.alert?.title) == L.holderCleardataAlertTitle()
		expect(sut.alert?.subTitle) == L.holderCleardataAlertSubtitle()
		expect(outcomes).to(beEmpty())
	}
	
	func test_menuOptionSelected_storedEvents_forHolder() {
		
		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)
		
		// When
		sut.menuOptionSelected(.storedEvents)
		
		// Then
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == .userWishesToSeeStoredEvents
	}
	
	func test_menuOptionSelected_deeplink_forHolder() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)

		// When
		sut.menuOptionSelected(.deeplink)

		// Then
		let url = URL(string: "https://web.acc.coronacheck.nl/verifier/scan?returnUri=https://web.acc.coronacheck.nl/app/open?returnUri=scanner-test")!
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == .openURL(url, inApp: false)
	}
	
	func test_resetData_holder() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)

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

		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == .coordinatorShouldRestart
	}
	
	func test_resetData_verifier() {

		// Given
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
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
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == .coordinatorShouldRestart
	}
	
	func test_menuOptionSelected_scanlog_forVerifier() {
		
		var outcomes = [AboutThisAppViewModel.Outcome]()
		let sut = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { outcome in
				outcomes.append(outcome)
			}
		)
		
		// When
		sut.menuOptionSelected(.scanlog)
		
		// Then
		expect(outcomes).to(haveCount(1))
		expect(outcomes[0]) == .userWishesToOpenScanLog
	}
}
