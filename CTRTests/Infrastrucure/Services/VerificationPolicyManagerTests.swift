/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble
import TestingShared
@testable import Models

class VerificationPolicyManagerTests: XCTestCase {

	private var sut: VerificationPolicyManager!
	private var secureUserSettingsSpy: SecureUserSettingsSpy!
	private var observerVCR: ObserverCallbackRecorder<VerificationPolicy?>!
	
	override func setUp() {

		super.setUp()
		secureUserSettingsSpy = SecureUserSettingsSpy()
		
		observerVCR = ObserverCallbackRecorder()
	}
	
	func test_withNoPreviousPolicy_isInitiallyNil() {
		
		// Arrange
		sut = VerificationPolicyManager(secureUserSettings: secureUserSettingsSpy)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		
		// Act
		// Assert
		expect(self.sut.state) == nil
		expect(self.observerVCR.values).to(beEmpty())
	}
	
	func test_withPreviousPolicySet_hasCorrectValue() {
		
		// Arrange
		secureUserSettingsSpy.stubbedVerificationPolicy = .policy3G
		sut = VerificationPolicyManager(secureUserSettings: secureUserSettingsSpy)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		
		// Act
		// Assert
		expect(self.sut.state) == .policy3G
		expect(self.observerVCR.values).to(beEmpty())
	}
	
	func test_receivedUpdate_notifiesObservers() {
		// Arrange
		secureUserSettingsSpy.stubbedVerificationPolicy = .policy3G
		sut = VerificationPolicyManager(secureUserSettings: secureUserSettingsSpy)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		
		// Act
		secureUserSettingsSpy.stubbedVerificationPolicy = .policy1G
		sut.update(verificationPolicy: .policy1G)
 
		// Assert
		expect(self.sut.state) == .policy1G
		expect(self.secureUserSettingsSpy.invokedVerificationPolicy) == .policy1G
		expect(self.secureUserSettingsSpy.invokedVerificationPolicySetterCount) == 1
	}
	
	func testWipePersistedDataClearsObserversAndNilsPolicy() {
		// Arrange
		secureUserSettingsSpy.stubbedVerificationPolicy = .policy3G
		sut = VerificationPolicyManager(secureUserSettings: secureUserSettingsSpy)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		
		// Act
		secureUserSettingsSpy.stubbedVerificationPolicy = nil
		sut.wipePersistedData()
				
		// Assert
		// Should reset keychain
		expect(self.secureUserSettingsSpy.invokedVerificationPolicy) == nil
		
		// State should be nil
		expect(self.sut.state) == nil
		
		// Update should not alert the observer:
		sut.update(verificationPolicy: .policy1G)
		expect(self.observerVCR.values).to(beEmpty())
	}
}
