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
    
    override func setUp() {
        
        super.setUp()
        remoteConfigManagerSpy = RemoteConfigManagingSpy(
            now: { now },
            userSettings: UserSettingsSpy(),
            reachability: ReachabilitySpy(),
            networkManager: NetworkSpy()
        )
        Services.use(remoteConfigManagerSpy)
        
        appVersionSupplierSpy = AppVersionSupplierSpy(version: "2.7.0", build: "1")
        
        sut = FeatureFlagManager(versionSupplier: appVersionSupplierSpy)
    }
    
    override func tearDown() {
        
        super.tearDown()
        Services.revertToDefaults()
    }

    func test_isVerificationPolicyEnabled_remoteConfig_nil() {
        
        // Given
        var config = RemoteConfiguration.default
        config.verificationPolicyVersion = nil
        remoteConfigManagerSpy.stubbedStoredConfiguration = config
        
        // When
        let enabled = sut.isVerificationPolicyEnabled()
        
        // Then
        expect(enabled) == false
    }
    
    func test_isVerificationPolicyEnabled_remoteConfig_disabled() {
        
        // Given
        var config = RemoteConfiguration.default
        config.verificationPolicyVersion = "0"
        remoteConfigManagerSpy.stubbedStoredConfiguration = config
        
        // When
        let enabled = sut.isVerificationPolicyEnabled()
        
        // Then
        expect(enabled) == false
    }

    func test_isVerificationPolicyEnabled_remoteConfig_lowerThanCurrentVersion() {
        
        // Given
        var config = RemoteConfiguration.default
        config.verificationPolicyVersion = "2.5.0"
        remoteConfigManagerSpy.stubbedStoredConfiguration = config
        
        // When
        let enabled = sut.isVerificationPolicyEnabled()
        
        // Then
        expect(enabled) == true
    }

    func test_isVerificationPolicyEnabled_remoteConfig_equalToCurrentVersion() {
        
        // Given
        var config = RemoteConfiguration.default
        config.verificationPolicyVersion = "2.7.0"
        remoteConfigManagerSpy.stubbedStoredConfiguration = config
        
        // When
        let enabled = sut.isVerificationPolicyEnabled()
        
        // Then
        expect(enabled) == true
    }

    func test_isVerificationPolicyEnabled_remoteConfig_higherThanCurrentVersion() {
        
        // Given
        var config = RemoteConfiguration.default
        config.verificationPolicyVersion = "3.0.0"
        remoteConfigManagerSpy.stubbedStoredConfiguration = config
        
        // When
        let enabled = sut.isVerificationPolicyEnabled()
        
        // Then
        expect(enabled) == false
    }
}
