/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
import XCTest
import Nimble

class FeatureFlagManagerTests: XCTestCase {
	
	private var sut: FeatureFlagManager!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	private var appVersionSupplierSpy: AppVersionSupplierSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		appVersionSupplierSpy = AppVersionSupplierSpy(version: "2.7.0", build: "1")
		
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.userSettingsSpy.stubbedOverrideDisclosurePolicies = []
		
		sut = FeatureFlagManager(versionSupplier: appVersionSupplierSpy, remoteConfigManager: remoteConfigManagerSpy)
	}
	
	func test_isVerificationPolicyEnabled_remoteConfig_nil() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicyVersion = nil
		
		// When
		let enabled = sut.isVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicyEnabled_remoteConfig_disabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicyVersion = "0"
		
		// When
		let enabled = sut.isVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicyEnabled_remoteConfig_lowerThanCurrentVersion() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicyVersion = "2.5.0"
		
		// When
		let enabled = sut.isVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_isVerificationPolicyEnabled_remoteConfig_equalToCurrentVersion() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicyVersion = "2.7.0"
		
		// When
		let enabled = sut.isVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_isVerificationPolicyEnabled_remoteConfig_higherThanCurrentVersion() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicyVersion = "3.0.0"
		
		// When
		let enabled = sut.isVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
		
	func test_isNewValidityInfoBannerEnabled_remoteConfig_enabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.showNewValidityInfoCard = true
		
		// When
		let enabled = sut.isNewValidityInfoBannerEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_isNewValidityInfoBannerEnabled_remoteConfig_disabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.showNewValidityInfoCard = false
		
		// When
		let enabled = sut.isNewValidityInfoBannerEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicy_1G_enabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["1G"]
		
		// When
		let enabled = sut.is1GVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_isVerificationPolicy_1G_disabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["3G"]
		
		// When
		let enabled = sut.is1GVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == false
	}

	func test_isVerificationPolicy_multiple_1Gdisabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["3G"]
		
		// When
		let enabled = sut.areMultipleVerificationPoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicy_multiple_3Gdisabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["1G"]
		
		// When
		let enabled = sut.areMultipleVerificationPoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicy_multiple_enabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["3G", "1G"]
		
		// When
		let enabled = sut.areMultipleVerificationPoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	// MARK: - Disclosure -
	
	func test_is1GExclusiveDisclosurePolicyEnabled_enabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["1G"]
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_is1GExclusiveDisclosurePolicyEnabled_disabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G"]
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is1GExclusiveDisclosurePolicyEnabled_disabled_bothPoliciesEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G", "1G"]
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is1GExclusiveDisclosurePolicyEnabled_disabled_noPoliciesEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = []
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_enabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G"]
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_disabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["1G"]
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_disabled_bothPoliciesEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G", "1G"]
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_disabled_noPoliciesEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = []
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_areBothDisclosurePoliciesEnabled_disabled_only1G() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["1G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_areBothDisclosurePoliciesEnabled_disabled_only3G() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_areBothDisclosurePoliciesEnabled_enabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["1G", "3G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_areBothDisclosurePoliciesEnabled_enabled_orderIndependent() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G", "1G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_overrideDisclosurePolicy_bothPoliciesEnabled_override1G() {
		
		// Given
		var config = RemoteConfiguration.default
		config.disclosurePolicies = ["3G", "1G"]
		remoteConfigManagerSpy.stubbedStoredConfiguration = config
		
		environmentSpies.userSettingsSpy.stubbedOverrideDisclosurePolicies = ["1G"]
		
		// When
		let bothPoliciesEnabled = sut.areBothDisclosurePoliciesEnabled()
		let only1GEnabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		let only3GEnabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(bothPoliciesEnabled) == false
		expect(only1GEnabled) == true
		expect(only3GEnabled) == false
	}
	
	func test_overrideDisclosurePolicy_bothPoliciesEnabled_override3G() {
		
		// Given
		var config = RemoteConfiguration.default
		config.disclosurePolicies = ["3G", "1G"]
		remoteConfigManagerSpy.stubbedStoredConfiguration = config
		
		environmentSpies.userSettingsSpy.stubbedOverrideDisclosurePolicies = ["3G"]
		
		// When
		let bothPoliciesEnabled = sut.areBothDisclosurePoliciesEnabled()
		let only1GEnabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		let only3GEnabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(bothPoliciesEnabled) == false
		expect(only1GEnabled) == false
		expect(only3GEnabled) == true
	}
}
