/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

class NewFeaturesManagerTests: XCTestCase {
	
	// MARK: - Setup
	var sut: NewFeaturesManager!
	private var secureUserSettingsSpy: SecureUserSettingsSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		
		// The direct dependencies of Managers are still injected in the init:
		secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedForcedInformationData = .empty
		sut = NewFeaturesManager(secureUserSettings: secureUserSettingsSpy)
		
		sut.factory = HolderNewFeaturesFactory()
	}
	
	// MARK: - Tests
	
	/// Test needs updating
	func testGetNeedsUpdating() {
		
		// Given
		sut.wipePersistedData()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == true
	}
	
	/// Test needs updating
	func testGetNeedsUpdating_verifier_disabled() {
		
		// Given
		sut.factory = VerifierNewFeaturesFactory()
		sut.wipePersistedData()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == false
	}
	
	func testConsentGiven() {
		
		// Given
		
		// When
		sut.consentGiven()
		
		// Then
		expect(self.secureUserSettingsSpy.invokedForcedInformationData?.lastSeenVersion) == sut.factory?.information.version
	}
	
	func test_getUpdatePage_holder() {
		
		// Given
		let expectedPage = NewFeatureItem(
			image: I.onboarding.tabbarNL(),
			tagline: L.holderUpdatepageTagline(),
			title: L.holderUpdatepageTitleTab(),
			content: L.holderUpdatepageContentTab()
		)
		
		// When
		let actualPage = sut.getNewFeatureItem()
		
		// Then
		expect(actualPage) == expectedPage
	}
	
	func test_getUpdatePage_verifier() {
		
		// Given
		let expectedPage = NewFeatureItem(
			image: I.onboarding.tabbarNL(),
			tagline: L.new_in_app_subtitle(),
			title: L.new_in_app_risksetting_title(),
			content: L.new_in_app_risksetting_subtitle()
		)
		sut.factory = VerifierNewFeaturesFactory()
		
		// When
		let actualPage = sut.getNewFeatureItem()
		
		// Then
		expect(actualPage) == expectedPage
	}
}
