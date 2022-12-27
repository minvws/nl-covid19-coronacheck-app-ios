/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

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
		expect(sut.appVersion) == "App versie verifier (build 1.2.3)"
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
}
