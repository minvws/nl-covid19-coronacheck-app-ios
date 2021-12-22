/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

class ForcedInformationManagerTests: XCTestCase {
	
	// MARK: - Setup
	var sut: ForcedInformationManager!
	var featureFlagManagerSpy: FeatureFlagManagerSpy!
	private var secureUserSettingsSpy: SecureUserSettingsSpy!
	
	override func setUp() {
		super.setUp()
		secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedForcedInformationData = .empty
		
		featureFlagManagerSpy = FeatureFlagManagerSpy()
		Services.use(featureFlagManagerSpy)
		
		sut = ForcedInformationManager(secureUserSettings: secureUserSettingsSpy)
		sut.factory = HolderForcedInformationFactory()
	}
	
	override func tearDown() {
		
		Services.secureUserSettings.reset()
		Services.revertToDefaults()
		super.tearDown()
	}
	
	// MARK: - Tests
	
	/// Test needs updating
	func testGetNeedsUpdating() {
		
		// Given
		Services.secureUserSettings.reset()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == true
	}
	
	/// Test needs updating
	func testGetNeedsUpdating_verifier_verificationPolicyEnabled() {
		
		// Given
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = true
		sut.factory = VerifierForcedInformationFactory()
		Services.secureUserSettings.reset()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == true
	}
	
	/// Test needs updating
	func testGetNeedsUpdating_verifier_verificationPolicyDisabled() {
		
		// Given
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		sut.factory = VerifierForcedInformationFactory()
		Services.secureUserSettings.reset()
		
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
		let expectedPage = ForcedInformationPage(
			image: I.onboarding.tabbarNL(),
			tagline: L.holderUpdatepageTagline(),
			title: L.holderUpdatepageTitleTab(),
			content: L.holderUpdatepageContentTab()
		)
		
		// When
		let actualPage = sut.getUpdatePage()
		
		// Then
		expect(actualPage) == expectedPage
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
		expect(actualPage) == expectedPage
	}
}
