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
	
	private var remoteConfigSpy: RemoteConfigManagingSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	private var scanLockManagerSpy: ScanLockManagerSpy!
	private var scanLogManagerSpy: ScanLogManagingSpy!
 
	override func setUp() {
		super.setUp()

		remoteConfigSpy = RemoteConfigManagingSpy()
		userSettingsSpy = UserSettingsSpy()
		riskLevelManagerSpy = RiskLevelManagerSpy()
		scanLockManagerSpy = ScanLockManagerSpy()
		scanLogManagerSpy = ScanLogManagingSpy()
		
		sut = VerificationPolicyEnabler(
			remoteConfigManager: remoteConfigSpy,
			userSettings: userSettingsSpy,
			riskLevelManager: riskLevelManagerSpy,
			scanLockManager: scanLockManagerSpy,
			scanLogManager: scanLogManagerSpy
		)
	}
	
	func test_enableVerificationPolicies_shouldStorePolicies() {
		// When
		sut.enable(verificationPolicies: ["3G"])
		
		// Then
		expect(self.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
	}
	
	func test_enableVerificationPolicies_whenPolicyIsStoredAndChanged_shoudResetScanMode() {
		// Given
		userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy3G]
		userSettingsSpy.stubbedPolicyInformationShown = true
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(self.riskLevelManagerSpy.invokedWipeScanMode) == true
		expect(self.scanLockManagerSpy.invokedWipeScanMode) == true
		expect(self.scanLogManagerSpy.invokedWipePersistedData) == true
		expect(self.userSettingsSpy.invokedPolicyInformationShown) == false
	}
	
	func test_enableVerificationPolicies_whenPolicyIsChangedButNotStored_shoudNotResetScanMode() {
		// Given
		userSettingsSpy.stubbedConfigVerificationPolicies = []
		userSettingsSpy.stubbedPolicyInformationShown = true
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(self.riskLevelManagerSpy.invokedWipeScanMode) == false
		expect(self.scanLockManagerSpy.invokedWipeScanMode) == false
		expect(self.scanLogManagerSpy.invokedWipePersistedData) == false
		expect(self.userSettingsSpy.invokedPolicyInformationShown).to(beNil())
	}
	
	func test_enableVerificationPolicies_shouldStoreKnownPolicies() {
		// When
		sut.enable(verificationPolicies: ["1G", "2G", "3G", "4G", "5G"])
		
		// Then
		expect(self.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G, VerificationPolicy.policy1G]
		expect(self.riskLevelManagerSpy.invokedUpdate) == false
	}
	
	func test_enableVerificationPolicies_shouldEnable3GPolicy() {
		// When
		sut.enable(verificationPolicies: ["3G"])
		
		// Then
		expect(self.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(self.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy).to(beNil())
	}
	
	func test_enableVerificationPolicies_shouldEnable1GPolicy() {
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(self.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy1G]
		expect(self.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy) == VerificationPolicy.policy1G
	}
	
	func test_enableVerificationPolicies_whenPoliciesAreEmpty_shouldEnable3GPolicy() {
		// When
		sut.enable(verificationPolicies: [])
		
		// Then
		expect(self.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(self.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy).to(beNil())
	}
	
	func test_wipePersistedData_shouldEnableDefaultPolicy() {
		// When
		sut.wipePersistedData()
		
		// Then
		expect(self.userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(self.riskLevelManagerSpy.invokedUpdateCount) == 1
		expect(self.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy).to(beNil())
	}
}
