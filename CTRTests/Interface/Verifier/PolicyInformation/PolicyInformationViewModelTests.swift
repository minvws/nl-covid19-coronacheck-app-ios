/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Shared
@testable import Models
@testable import Managers
@testable import Resources

final class PolicyInformationViewModelTests: XCTestCase {
	
	private var sut: PolicyInformationViewModel!
	
	private var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
	}
	
	func test_bindings_whenPolicyStateIsNilAndMultiplePoliciesAreEnabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.sut.tagline) == L.new_policy_subtitle()
		expect(self.sut.title) == L.new_in_app_risksetting_title()
		expect(self.sut.content) == L.new_in_app_risksetting_subtitle()
		expect(self.sut.primaryButtonTitle) == L.generalNext()
	}
	
	func test_bindings_whenPolicyStateIsSetAndMultiplePoliciesAreEnabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.sut.tagline) == L.new_policy_subtitle()
		expect(self.sut.title) == L.new_in_app_risksetting_title()
		expect(self.sut.content) == L.new_in_app_risksetting_subtitle()
		expect(self.sut.primaryButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_bindings_whenPolicyStateIsSetAndMultiplePoliciesAreDisabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.sut.tagline) == L.new_policy_subtitle()
		expect(self.sut.title) == L.new_policy_1G_title()
		expect(self.sut.content) == L.new_policy_1G_subtitle()
		expect(self.sut.primaryButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_bindings_whenPolicyStateIsNilAndMultiplePoliciesAreDisabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.sut.tagline) == L.new_policy_subtitle()
		expect(self.sut.title) == L.new_policy_1G_title()
		expect(self.sut.content) == L.new_policy_1G_subtitle()
		expect(self.sut.primaryButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_finish_whenPolicyStateIsNilAndMultiplePoliciesAreEnabled_shouldShowRiskSetting() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == true
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
	}
	
	func test_finish_whenPolicyStateIsSetAndMultiplePoliciesAreEnabled_shouldInvokeCoordinatorComplete() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
	}
	
	func test_finish_whenPolicyStateIsSetAndMultiplePoliciesAreDisabled_shouldInvokeCoordinatorComplete() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
	}
	
	func test_finish_whenPolicyStateIsNilAndMultiplePoliciesAreDisabled_shouldInvokeCoordinatorComplete() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSelectRiskSetting) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
	}
	
	func test_finish_shouldSaveToUserDefaults() {
		// Given
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut.finish()
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedPolicyInformationShown) == true
	}
}
