/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
import TestingShared
@testable import Managers

class FeatureFlagManagerTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (FeatureFlagManager, RemoteConfigManagingSpy) {
			
		let remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		
		let userSettingsSpy = UserSettingsSpy()
		
		let sut = FeatureFlagManager(
			now: { now },
			remoteConfigManager: remoteConfigManagerSpy,
			userSettings: userSettingsSpy
		)
		
		trackForMemoryLeak(instance: remoteConfigManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: userSettingsSpy, file: file, line: line)
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, remoteConfigManagerSpy)
	}

	func test_isVerificationPolicy_1G_enabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["1G"]
		
		// When
		let enabled = sut.is1GVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_isVerificationPolicy_1G_disabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["3G"]
		
		// When
		let enabled = sut.is1GVerificationPolicyEnabled()
		
		// Then
		expect(enabled) == false
	}

	func test_isVerificationPolicy_multiple_1Gdisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["3G"]
		
		// When
		let enabled = sut.areMultipleVerificationPoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicy_multiple_3Gdisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["1G"]
		
		// When
		let enabled = sut.areMultipleVerificationPoliciesEnabled()
		
		// Then
		expect(enabled) == false
	}
	
	func test_isVerificationPolicy_multiple_enabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.verificationPolicies = ["3G", "1G"]
		
		// When
		let enabled = sut.areMultipleVerificationPoliciesEnabled()
		
		// Then
		expect(enabled) == true
	}
	
	func test_isGGDEnabled_GGDDisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isGGDEnabled = false
		
		// When
		let flag = sut.isGGDEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDEnabled_defaultToFalseWhenNil() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isGGDEnabled = nil
		
		// When
		let flag = sut.isGGDEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDEnabled_GGDEnabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isGGDEnabled = true
		
		// When
		let flag = sut.isGGDEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isGGDPortalEnabled_GGDPortalDisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isPAPEnabled = false
		
		// When
		let flag = sut.isGGDPortalEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDPortalEnabled_defaultToFalseWhenNil() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isPAPEnabled = nil
		
		// When
		let flag = sut.isGGDPortalEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isGGDPortalEnabled_GGDPortalEnabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isPAPEnabled = true
		
		// When
		let flag = sut.isGGDPortalEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isLunhCheckEnabled_lunhCheckDisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isLuhnCheckEnabled = false
		
		// When
		let flag = sut.isLuhnCheckEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isLuhnCheckEnabled_defaultToFalseWhenNil() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isLuhnCheckEnabled = nil
		
		// When
		let flag = sut.isLuhnCheckEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isLuhnCheckEnabled_luhnCheckEnabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.isLuhnCheckEnabled = true
		
		// When
		let flag = sut.isLuhnCheckEnabled()
		
		// Then
		expect(flag) == true
	}
		
	func test_isMigrateButtonEnabled_migrationButtonEnabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.migrateButtonEnabled = true
		
		// When
		let flag = sut.isMigrationEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isMigrateButtonEnabled_migrationButtonDisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.migrateButtonEnabled = false
		
		// When
		let flag = sut.isMigrationEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isAddingEventsEnabled_addEventsButtonEnabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.addEventsButtonEnabled = true
		
		// When
		let flag = sut.isAddingEventsEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isAddingEventsEnabled_addEventsButtonDisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.addEventsButtonEnabled = false
		
		// When
		let flag = sut.isAddingEventsEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isScanningEventsEnabled_scanCertificateButtonEnabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.scanCertificateButtonEnabled = true
		
		// When
		let flag = sut.isScanningEventsEnabled()
		
		// Then
		expect(flag) == true
	}
	
	func test_isScanningEventsEnabled_scanCertificateButtonDisabled() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.scanCertificateButtonEnabled = false
		
		// When
		let flag = sut.isScanningEventsEnabled()
		
		// Then
		expect(flag) == false
	}
	
	func test_isInArchiveMode_noArchiveDate() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.archiveOnlyDate = nil
		
		// When
		let flag = sut.isInArchiveMode()
		
		// Then
		expect(flag) == false
	}
	
	func test_isInArchiveMode_archiveDateBeforeNow() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		let archiveOnlyDate = Formatter.getDateFrom(dateString8601: "2022-07-01T23:00:00z")
		remoteConfigManagerSpy.stubbedStoredConfiguration.archiveOnlyDate = archiveOnlyDate
		
		// When
		let flag = sut.isInArchiveMode()
		
		// Then
		expect(flag) == false
	}
	
	func test_isInArchiveMode_archiveDateAfterNow() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		let archiveOnlyDate = Formatter.getDateFrom(dateString8601: "2021-07-01T23:00:00z")
		remoteConfigManagerSpy.stubbedStoredConfiguration.archiveOnlyDate = archiveOnlyDate
		
		// When
		let flag = sut.isInArchiveMode()
		
		// Then
		expect(flag) == true
	}
}
