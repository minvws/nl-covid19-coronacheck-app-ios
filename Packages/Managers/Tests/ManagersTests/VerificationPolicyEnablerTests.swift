/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import Models
@testable import Managers
@testable import Shared
import TestingShared

final class VerificationPolicyEnablerTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (VerificationPolicyEnabler, UserSettingsSpy, VerificationPolicyManagerSpy, ScanLockManagerSpy, ScanLogManagingSpy) {
			
		let remoteConfigManagerSpy = RemoteConfigManagingSpy()
		(remoteConfigManagerSpy.stubbedObservatoryForUpdates, _) = Observatory<RemoteConfigManager.ConfigNotification>.create()
		
		let userSettingsSpy = UserSettingsSpy()
		let verificationPolicyManagerSpy = VerificationPolicyManagerSpy()
		let scanLockManagerSpy = ScanLockManagerSpy()
		let scanLogManagerSpy = ScanLogManagingSpy()
		
		let sut = VerificationPolicyEnabler(
			remoteConfigManager: remoteConfigManagerSpy,
			userSettings: userSettingsSpy,
			verificationPolicyManager: verificationPolicyManagerSpy,
			scanLockManager: scanLockManagerSpy,
			scanLogManager: scanLogManagerSpy
		)
		trackForMemoryLeak(instance: remoteConfigManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: userSettingsSpy, file: file, line: line)
		trackForMemoryLeak(instance: verificationPolicyManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: scanLockManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: scanLogManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, userSettingsSpy, verificationPolicyManagerSpy, scanLockManagerSpy, scanLogManagerSpy)
	}
	
	func test_enableVerificationPolicies_shouldStorePolicies() {
		
		// Given
		let (sut, userSettingsSpy, _, _, _) = makeSUT()
		
		// When
		sut.enable(verificationPolicies: ["3G"])
		
		// Then
		expect(userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
	}
	
	func test_enableVerificationPolicies_whenPolicyIsStoredAndChanged_shoudResetScanMode() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, scanLockManagerSpy, scanLogManagerSpy) = makeSUT()
		userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy3G]
		userSettingsSpy.stubbedPolicyInformationShown = true
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(verificationPolicyManagerSpy.invokedWipeScanMode) == true
		expect(scanLockManagerSpy.invokedWipeScanMode) == true
		expect(scanLogManagerSpy.invokedWipePersistedData) == true
		expect(userSettingsSpy.invokedPolicyInformationShown) == false
	}
	
	func test_enableVerificationPolicies_whenPolicyIsChangedButNotStored_shoudNotResetScanMode() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, scanLockManagerSpy, scanLogManagerSpy) = makeSUT()
		userSettingsSpy.stubbedConfigVerificationPolicies = []
		userSettingsSpy.stubbedPolicyInformationShown = true
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(verificationPolicyManagerSpy.invokedWipeScanMode) == false
		expect(scanLockManagerSpy.invokedWipeScanMode) == false
		expect(scanLogManagerSpy.invokedWipePersistedData) == false
		expect(userSettingsSpy.invokedPolicyInformationShown) == nil
	}
	
	func test_enableVerificationPolicies_shouldStoreKnownPolicies() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, _, _) = makeSUT()
		
		// When
		sut.enable(verificationPolicies: ["1G", "2G", "3G", "4G", "5G"])
		
		// Then
		expect(userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G, VerificationPolicy.policy1G]
		expect(verificationPolicyManagerSpy.invokedUpdate) == false
	}
	
	func test_enableVerificationPolicies_shouldEnable3GPolicy() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, _, _) = makeSUT()
		
		// When
		sut.enable(verificationPolicies: ["3G"])
		
		// Then
		expect(userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(verificationPolicyManagerSpy.invokedUpdateCount) == 1
		expect(verificationPolicyManagerSpy.invokedUpdateParameters?.verificationPolicy) == nil
	}
	
	func test_enableVerificationPolicies_shouldEnable1GPolicy() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, _, _) = makeSUT()
		
		// When
		sut.enable(verificationPolicies: ["1G"])
		
		// Then
		expect(userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy1G]
		expect(verificationPolicyManagerSpy.invokedUpdateCount) == 1
		expect(verificationPolicyManagerSpy.invokedUpdateParameters?.verificationPolicy) == VerificationPolicy.policy1G
	}
	
	func test_enableVerificationPolicies_whenPoliciesAreEmpty_shouldEnable3GPolicy() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, _, _) = makeSUT()
		
		// When
		sut.enable(verificationPolicies: [])
		
		// Then
		expect(userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(verificationPolicyManagerSpy.invokedUpdateCount) == 1
		expect(verificationPolicyManagerSpy.invokedUpdateParameters?.verificationPolicy) == nil
	}
	
	func test_wipePersistedData_shouldEnableDefaultPolicy() {
		
		// Given
		let (sut, userSettingsSpy, verificationPolicyManagerSpy, _, _) = makeSUT()
		
		// When
		sut.wipePersistedData()
		
		// Then
		expect(userSettingsSpy.invokedConfigVerificationPolicies) == [VerificationPolicy.policy3G]
		expect(verificationPolicyManagerSpy.invokedUpdateCount) == 1
		expect(verificationPolicyManagerSpy.invokedUpdateParameters?.verificationPolicy) == nil
	}
}
