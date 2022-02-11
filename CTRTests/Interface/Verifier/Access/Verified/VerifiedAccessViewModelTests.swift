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
			verifiedAccess: .verified(.policy3G)
		)
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_accessTitle_demoLowRisk_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.policy3G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_policy(VerificationPolicy.policy3G.localization)
	}
	
	func test_accessTitle_demoLowRisk_verificationPolicyDisabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.policy3G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_demoHighRisk_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.policy1G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_policy(VerificationPolicy.policy1G.localization)
	}
	
	func test_accessTitle_demoHighRisk_verificationPolicyDisabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .demo(.policy1G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_verifiedLowRisk_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.policy3G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_policy(VerificationPolicy.policy3G.localization)
	}
	
	func test_accessTitle_verifiedLowRisk_verificationPolicyDisabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.policy3G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
	
	func test_accessTitle_verifiedHighRisk_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.policy1G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_policy(VerificationPolicy.policy1G.localization)
	}
	
	func test_accessTitle_verifiedHighRisk_verificationPolicyDisabled() {
		
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedAccess: .verified(.policy1G)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title()
	}
}
