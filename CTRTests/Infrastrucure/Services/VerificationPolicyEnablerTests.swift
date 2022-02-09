/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

final class VerificationPolicyEnablerTests: XCTestCase {
	
	private var sut: VerificationPolicyEnabler!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		
		sut = VerificationPolicyEnabler()
	}
	
	func test_enableVerificationPolicies_shouldStorePolicies() {
		// When
		sut.enable(verificationPolicies: ["3G"])
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
	}
	
	func test_enableVerificationPolicies_whenPolicyIsStoredAndChanged_shoudResetScanMode() {
		// Given
		environmentSpies.userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy3G]
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = true
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(self.environmentSpies.riskLevelManagerSpy.invokedWipeScanMode) == true
		expect(self.environmentSpies.scanLockManagerSpy.invokedWipeScanMode) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.userSettingsSpy.invokedPolicyInformationShown) == false
	}
	
	func test_enableVerificationPolicies_whenPolicyIsChangedButNotStored_shoudNotResetScanMode() {
		// Given
		environmentSpies.userSettingsSpy.stubbedConfigVerificationPolicies = []
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = true
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(self.environmentSpies.riskLevelManagerSpy.invokedWipeScanMode) == false
		expect(self.environmentSpies.scanLockManagerSpy.invokedWipeScanMode) == false
		expect(self.environmentSpies.scanLogManagerSpy.invokedWipePersistedData) == false
		expect(self.environmentSpies.userSettingsSpy.invokedPolicyInformationShown).to(beNil())
	}
	
	func test_enableVerificationPolicies_shouldStoreKnownPolicies() {
		// When
		sut.enable(verificationPolicies: ["1G", "2G", "3G", "4G", "5G"])
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G, VerificationPolicy.policy1G]
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdate) == false
	}
	
	func test_enableVerificationPolicies_shouldEnable3GPolicy() {
		// When
		sut.enable(verificationPolicies: ["3G"])
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy).to(beNil())
	}
	
	func test_enableVerificationPolicies_shouldEnable1GPolicy() {
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy1G]
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy) == VerificationPolicy.policy1G
	}
	
	func test_enableVerificationPolicies_whenPoliciesAreEmpty_shouldEnable3GPolicy() {
		// When
		sut.enable(verificationPolicies: [])
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy).to(beNil())
	}
	
	func test_wipePersistedData_shouldEnableDefaultPolicy() {
		// When
		sut.wipePersistedData()
		
		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.environmentSpies.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy).to(beNil())
	}
}
