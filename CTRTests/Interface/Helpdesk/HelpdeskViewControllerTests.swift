/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR
import Nimble
import SnapshotTesting
import TestingShared
@testable import Managers

class HelpdeskViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: HelpdeskViewController!
	private var environmentSpies: EnvironmentSpies!
	
	var window: UIWindow!
	
	// MARK: Test lifecycle
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		environmentSpies.userSettingsSpy.stubbedConfigFetchedHash = "hereisanicelongshahashforthistest"
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "<a href=\"tel:TEST\">TEST</a>"
		environmentSpies.contactInformationSpy.stubbedPhoneNumberAbroadLink = "<a href=\"tel:TEST 2\">TEST 2</a>"
		environmentSpies.contactInformationSpy.stubbedOpeningDays = "maandag t/m vrijdag"
		environmentSpies.contactInformationSpy.stubbedStartHour = "08:00"
		environmentSpies.contactInformationSpy.stubbedEndHour = "18:00"
		window = UIWindow()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: Test
	
	func test_content_holder() {
		
		// Given
		let viewModel = HelpdeskViewModel(
			flavor: .holder,
			versionSupplier: AppVersionSupplierSpy(version: "holder", build: "1.2.3"),
			urlHandler: { _ in }
		)
		
		sut = HelpdeskViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		sut.assertImage()
	}
	
	func test_content_verifier() {
		
		// Given
		let viewModel = HelpdeskViewModel(
			flavor: .verifier,
			versionSupplier: AppVersionSupplierSpy(version: "verifier", build: "1.2.3"),
			urlHandler: { _ in }
		)
		
		sut = HelpdeskViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		sut.assertImage()
	}
}
