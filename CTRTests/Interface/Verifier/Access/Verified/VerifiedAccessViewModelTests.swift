/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

final class VerifiedAccessViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: VerifiedAccessViewModel!
	
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_dismiss_shouldNavigateBackToStart() {
		
		// Given
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.low)
		)
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_accessTitle_demoLowRisk_verificationPolicyEnabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.low)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_lowrisk()
	}
	
	func test_accessTitle_demoLowRisk_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.low)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_demoHighRisk_verificationPolicyEnabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.high)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_highrisk()
	}
	
	func test_accessTitle_demoHighRisk_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.high)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_demoHighPlusRisk_verificationPolicyEnabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.highPlus)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_2g_plus()
	}
	
	func test_accessTitle_demoHighPlusRisk_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.highPlus)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_verifiedLowRisk_verificationPolicyEnabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.low)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_lowrisk()
	}
	
	func test_accessTitle_verifiedLowRisk_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.low)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_verifiedHighRisk_verificationPolicyEnabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.high)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_highrisk()
	}
	
	func test_accessTitle_verifiedHighRisk_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.high)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_verifiedHighPlusRisk_verificationPolicyEnabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.highPlus)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_2g_plus()
	}
	
	func test_accessTitle_verifiedHighPlusRisk_verificationPolicyDisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.highPlus)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
}
