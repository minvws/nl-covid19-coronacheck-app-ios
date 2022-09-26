/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.userSettingsSpy.stubbedOverrideDisclosurePolicies = []
		
		sut = FeatureFlagManager(remoteConfigManager: remoteConfigManagerSpy)
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
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["1G"]
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_is1GExclusiveDisclosurePolicyEnabled_disabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G"]
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is1GExclusiveDisclosurePolicyEnabled_disabled_bothPoliciesEnabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G", "1G"]
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is1GExclusiveDisclosurePolicyEnabled_disabled_noPoliciesEnabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = []
		
		// When
		let enabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_enabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G"]
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_disabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["1G"]
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is3GExclusiveDisclosurePolicyEnabled_disabled_bothPoliciesEnabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G", "1G"]
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_is3GExclusiveDisclosurePolicyDisabled_disabled_noPoliciesEnabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = []
		
		// When
		let enabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isNoDisclosurePoliciesEnabled_noPoliciesEnabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = []
		
		// When
		let enabled = sut.areZeroDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_areBothDisclosurePoliciesEnabled_disabled_only1G() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["1G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_areBothDisclosurePoliciesEnabled_disabled_only3G() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_areBothDisclosurePoliciesEnabled_enabled() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["1G", "3G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_areBothDisclosurePoliciesEnabled_enabled_orderIndependent() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G", "1G"]
		
		// When
		let enabled = sut.areBothDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_overrideDisclosurePolicy_bothPoliciesEnabled_override1G() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["1G"]
		
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
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = ["3G"]
		
		// When
		let bothPoliciesEnabled = sut.areBothDisclosurePoliciesEnabled()
		let only1GEnabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		let only3GEnabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		
		// Then
		expect(bothPoliciesEnabled) == false
		expect(only1GEnabled) == false
		expect(only3GEnabled) == true
	}
	
	func test_overrideDisclosurePolicy_bothPoliciesEnabled_override0G() {
		
		// Given
		environmentSpies.disclosurePolicyManagingSpy.stubbedGetDisclosurePoliciesResult = []
		environmentSpies.userSettingsSpy.stubbedOverrideDisclosurePolicies = ["0G"]
		
		// When
		let bothPoliciesEnabled = sut.areBothDisclosurePoliciesEnabled()
		let only1GEnabled = sut.is1GExclusiveDisclosurePolicyEnabled()
		let only3GEnabled = sut.is3GExclusiveDisclosurePolicyEnabled()
		let noPoliciesEnabled = sut.areZeroDisclosurePoliciesEnabled()
		
		// Then
		expect(bothPoliciesEnabled) == false
		expect(only1GEnabled) == false
		expect(only3GEnabled) == false
		expect(noPoliciesEnabled) == true
	}
	
	func test_isGGDEnabled_GGDDisabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isGGDEnabled = false
		
		// When
		let flag = sut.isGGDEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDEnabled_defaultToFalseWhenNil() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isGGDEnabled = nil
		
		// When
		let flag = sut.isGGDEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDEnabled_GGDEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isGGDEnabled = true
		
		// When
		let flag = sut.isGGDEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isGGDPortalEnabled_GGDPortalDisabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isPAPEnabled = false
		
		// When
		let flag = sut.isGGDPortalEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDPortalEnabled_defaultToFalseWhenNil() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isPAPEnabled = nil
		
		// When
		let flag = sut.isGGDPortalEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDPortalEnabled_GGDPortalEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isPAPEnabled = true
		
		// When
		let flag = sut.isGGDPortalEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isLunhCheckEnabled_lunhCheckDisabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isLuhnCheckEnabled = false
		
		// When
		let flag = sut.isLuhnCheckEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isLuhnCheckEnabled_defaultToFalseWhenNil() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isLuhnCheckEnabled = nil
		
		// When
		let flag = sut.isLuhnCheckEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isLuhnCheckEnabled_luhnCheckEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.isLuhnCheckEnabled = true
		
		// When
		let flag = sut.isLuhnCheckEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isVisitorPassEnabled_visitorPassDisabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.visitorPassEnabled = false
		
		// When
		let flag = sut.isVisitorPassEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isVisitorPassEnabled_defaultToFalseWhenNil() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.visitorPassEnabled = nil
		
		// When
		let flag = sut.isVisitorPassEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isVisitorPassEnabled_visitorPassEnabled() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.visitorPassEnabled = true
		
		// When
		let flag = sut.isVisitorPassEnabled()
		
		// Then
		expect(flag) == true
	}
}
