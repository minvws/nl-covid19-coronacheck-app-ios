/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		environmentSpies.riskLevelManagerSpy.stubbedState = .low
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
		expect(self.sut.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"

		expect(self.sut.riskLevel) == .low
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
		
		sut.selectRisk = .high
		
		// When
		sut.confirmSetting()
		
		// When
		expect(self.environmentSpies.riskLevelManagerSpy.invokedStateGetter) == true
	}
	
	func test_changingLevelWithinTimeWindow_enablesLock() {
		// Arrange
		environmentSpies.riskLevelManagerSpy.stubbedState = .low
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = true
		
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		// Act
		sut.selectRisk = .high
		sut.confirmSetting()
		
		// Fish in Alert for OK action & trigger it:
		expect(self.sut.alert).toNot(beNil())
		sut.alert?.okAction?(UIAlertAction())
		
		// Assert
		expect(self.environmentSpies.scanLockManagerSpy.invokedLockCount) == 1
	}
	
	func test_changingLevelOutsideOfTimeWindow_doesNotEnableLock() {
		// Arrange
		environmentSpies.riskLevelManagerSpy.stubbedState = .low
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = false
		
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy
		)
		
		// Act
		sut.selectRisk = .high
		sut.confirmSetting()
		
		// Fish in Alert for OK action & trigger it:
		expect(self.sut.alert).to(beNil())
		expect(self.environmentSpies.scanLockManagerSpy.invokedLock) == false
	}
}
