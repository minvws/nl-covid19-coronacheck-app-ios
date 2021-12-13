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
	
	override func setUp() {
		
		featureFlagManagerSpy = FeatureFlagManagerSpy()
		Services.use(featureFlagManagerSpy)
		
		sut = ForcedInformationManager()
		sut.factory = HolderForcedInformationFactory()
		super.setUp()
	}
	
	override func tearDown() {
		
		sut.reset()
		Services.revertToDefaults()
		super.tearDown()
	}
	
	// MARK: - Tests
	
	/// Test needs updating
	func testGetNeedsUpdating() {
		
		// Given
		sut.reset()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == true
	}
	
	/// Test needs updating
	func testGetNeedsUpdating_verifier_verificationPolicyEnabled() {
		
		// Given
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = true
		sut.factory = VerifierForcedInformationFactory()
		sut.reset()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == true
	}
	
	/// Test needs updating
	func testGetNeedsUpdating_verifier_verificationPolicyDisabled() {
		
		// Given
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		sut.factory = VerifierForcedInformationFactory()
		sut.reset()
		
		// When
		
		// Then
		expect(self.sut.needsUpdating) == false
	}
	
	func testConsentGiven() {
		
		// Given
		
		// When
		sut.consentGiven()
		
		// Then
		expect(self.sut.needsUpdating) == false
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
