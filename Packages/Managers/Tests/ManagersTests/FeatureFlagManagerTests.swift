/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import Managers

class FeatureFlagManagerTests: XCTestCase {
	
	private var sut: FeatureFlagManager!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	private var appVersionSupplierSpy: AppVersionSupplierSpy!
	private var userSettingsSpy: UserSettingsSpy!
	
	override func setUp() {
		
		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		
		userSettingsSpy = UserSettingsSpy()
		
		sut = FeatureFlagManager(
			remoteConfigManager: remoteConfigManagerSpy,
			userSettings: userSettingsSpy
		)
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
	
	func test_isNoDisclosurePoliciesEnabled_noPoliciesEnabled() {
		
		// Given
		
		// When
		let enabled = sut.areZeroDisclosurePoliciesEnabled()
		
		// Then
		expect(enabled) == true
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
}
