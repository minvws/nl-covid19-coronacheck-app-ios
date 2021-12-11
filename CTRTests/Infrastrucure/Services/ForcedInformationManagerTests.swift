/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ForcedInformationManagerTests: XCTestCase {

	// MARK: - Setup
	var sut: ForcedInformationManager!
	private var secureUserSettingsSpy: SecureUserSettingsSpy!
	
	override func setUp() {
		super.setUp()
		secureUserSettingsSpy = SecureUserSettingsSpy()
		
		sut = ForcedInformationManager(secureUserSettings: secureUserSettingsSpy)
		sut.factory = HolderForcedInformationFactory()
	}

	override func tearDown() {

		sut.reset()
		super.tearDown()
	}

	// MARK: - Tests

	/// Test needs updating
	func testGetNeedsUpdating() {

		// Given
		sut.reset()

		// When

		// Then
		XCTAssertTrue(sut.needsUpdating)
	}

	func testConsentGiven() {

		// Given

		// When
		sut.consentGiven()

		// Then
		XCTAssertFalse(sut.needsUpdating)
	}

	func test_getUpdatePage_holder() {

		// Given
		let expectedPage = ForcedInformationPage(
			image: I.onboarding.tabbarNL(),
			tagline: L.holderUpdatepageTagline(),
			title: L.holderUpdatepageTitleTab(),
			content: L.holderUpdatepageContentTab()
		)

		// When
		let actualPage = sut.getUpdatePage()

		// Then
		XCTAssertEqual(actualPage, expectedPage)
	}
	
	func test_getUpdatePage_verifier() {

		// Given
		let expectedPage = ForcedInformationPage(
			image: I.onboarding.tabbarNL(),
			tagline: L.new_in_app_subtitle(),
			title: L.new_in_app_risksetting_title(),
			content: L.new_in_app_risksetting_subtitle()
		)
		sut.factory = VerifierForcedInformationFactory()

		// When
		let actualPage = sut.getUpdatePage()

		// Then
		XCTAssertEqual(actualPage, expectedPage)
	}
}
