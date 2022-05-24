/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Rswift

final class RiskSettingSelectedViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: RiskSettingSelectedViewModel!
	
	/// The coordinator spy
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
	}

	// MARK: - Tests
	
	func test_bindings() {
		// Given
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		// When
		
		// Then
		expect(self.sut.title) == L.verifier_risksetting_active_title()
		expect(self.sut.header).to(beNil())
		expect(self.sut.lowRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		expect(self.sut.lowRiskSubtitle) == L.verifier_risksetting_subtitle_3G()
		expect(self.sut.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)), \(L.verifier_risksetting_subtitle_3G())"
		expect(self.sut.highRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		expect(self.sut.highRiskSubtitle) == L.verifier_risksetting_subtitle_1G()
		expect(self.sut.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)), \(L.verifier_risksetting_subtitle_1G())"

		expect(self.sut.verificationPolicy) == .policy3G
	}

	func test_header_withWarning() {
		
		// Given
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = true
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		// When

		// Then
		expect(self.sut.header) == L.verifier_risksetting_active_lock_warning_header(5)
	}
	
	func test_header_withoutWarning() {
		
		// Given
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = false
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		// When

		// Then
		expect(self.sut.header).to(beNil())
	}
	
	func test_confirmSetting_shouldSetHighRisk() {
		// Given
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		sut.selectVerificationPolicy = .policy1G
		
		// When
		sut.confirmSetting()
		
		// When
		expect(self.environmentSpies.verificationPolicyManagerSpy.invokedStateGetter) == true
	}
	
	func test_changingLevelWithinTimeWindow_enablesLock() {
		// Arrange
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = true
		
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		// Act
		sut.selectVerificationPolicy = .policy1G
		sut.confirmSetting()
		
		// Fish in Alert for OK action & trigger it:
		expect(self.sut.alert).toNot(beNil())
		sut.alert?.okAction?(UIAlertAction())
		
		// Assert
		expect(self.environmentSpies.scanLockManagerSpy.invokedLockCount) == 1
	}
	
	func test_changingLevelOutsideOfTimeWindow_doesNotEnableLock() {
		// Arrange
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = false
		
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		// Act
		sut.selectVerificationPolicy = .policy3G
		sut.confirmSetting()
		
		// Fish in Alert for OK action & trigger it:
		expect(self.sut.alert).to(beNil())
		expect(self.environmentSpies.scanLockManagerSpy.invokedLock) == false
	}
}
