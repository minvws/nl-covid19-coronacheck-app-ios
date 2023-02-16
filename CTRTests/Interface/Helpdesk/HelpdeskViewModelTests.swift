/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
import TestingShared
import Shared
@testable import CTR
@testable import Managers
@testable import Resources

class HelpdeskViewModelTests: XCTestCase {
	
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_configVersion_forVerifier() {
		// Arrange
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		
		let sut = HelpdeskViewModel(flavor: .verifier, versionSupplier: AppVersionSupplierSpy(version: "verifier", build: "1.2.3"), urlHandler: { _ in })
		
		// Assert
		expect(sut.configVersion) == "hereisa, 15-07-2021 17:02"
		expect(sut.appVersion) == "verifier (build 1.2.3)"
	}
	
	func test_configVersion_forHolder() {
		// Arrange
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		
		let sut = HelpdeskViewModel(flavor: .holder, versionSupplier: AppVersionSupplierSpy(version: "holder", build: "1.2.3"), urlHandler: { _ in })
		
		// Assert
		expect(sut.configVersion) == "hereisa, 15-07-2021 17:02"
		expect(sut.appVersion) == "holder (build 1.2.3)"
	}
	
	func test_urlHandler() {
		// Arrange
		let urlExpected = URL(string: "https://coronacheck.nl")!
		var urlTapped: URL?
		
		let sut = HelpdeskViewModel(flavor: .holder, versionSupplier: AppVersionSupplierSpy(version: "holder"), urlHandler: { url in
			urlTapped = url
		})
		
		// Act
		sut.userDidTapURL(url: urlExpected)
		
		// Assert
		expect(urlTapped) == urlExpected
	}
	
	func test_contactInfo() {
		
		// Arrange
		environmentSpies.contactInformationSpy.stubbedStartHour = "08:00"
		environmentSpies.contactInformationSpy.stubbedOpeningDays = "elke dag"
		environmentSpies.contactInformationSpy.stubbedEndHour = "12:00"
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "TEST 1"
		environmentSpies.contactInformationSpy.stubbedPhoneNumberAbroadLink = "TEST 2"
		
		// Act
		let sut = HelpdeskViewModel(flavor: .holder, versionSupplier: AppVersionSupplierSpy(version: "holder", build: "1.2.3"), urlHandler: { _ in })
		
		// Assert
		expect(sut.messageLine1) == L.holder_helpdesk_contact_message_line1("TEST 1")
		expect(sut.messageLine2) == L.holder_helpdesk_contact_message_line2("TEST 2")
		expect(sut.messageLine3) == L.holder_helpdesk_contact_message_line3("elke dag", "08:00", "12:00")
	}
}
