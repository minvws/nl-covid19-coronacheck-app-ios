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
	private var riskLevelManagingSpy: RiskLevelManagerSpy!
	private var scanLogManagingSpy: ScanLogManagingSpy!
	private var scanLockManagingSpy: ScanLockManagerSpy!
	
	override func setUp() {
		super.setUp()
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		riskLevelManagingSpy = RiskLevelManagerSpy()
		riskLevelManagingSpy.stubbedState = .low

		scanLogManagingSpy = ScanLogManagingSpy()
		scanLogManagingSpy.stubbedDidWeScanQRsResult = false
		Services.use(scanLogManagingSpy)
		
		scanLockManagingSpy = ScanLockManagerSpy()
		scanLockManagingSpy.stubbedState = .unlocked
		scanLockManagingSpy.stubbedAppendObserverResult = UUID()
		
		Services.use(scanLockManagingSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}
	
	// MARK: - Tests
	
	func test_bindings() {
		// Given
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLogManager: scanLogManagingSpy,
			scanLockManager: scanLockManagingSpy,
			configuration: .default
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
		scanLogManagingSpy.stubbedDidWeScanQRsResult = true
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLogManager: scanLogManagingSpy,
			scanLockManager: scanLockManagingSpy,
			configuration: .default
		)
		
		// When

		// Then
		expect(self.sut.header) == L.verifier_risksetting_active_lock_warning_header(5)
	}
	
	func test_confirmSetting_shouldSetHighRisk() {
		// Given
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLogManager: scanLogManagingSpy,
			scanLockManager: scanLockManagingSpy,
			configuration: .default
		)
		
		sut.selectRisk = .high
		
		// When
		sut.confirmSetting()
		
		// When
		expect(self.riskLevelManagingSpy.invokedStateGetter) == true
	}
	
	func test_changingLevelWithinTimeWindow_enablesLock() {
		// Arrange
		riskLevelManagingSpy.stubbedState = .low
		scanLogManagingSpy.stubbedDidWeScanQRsResult = true
		
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLogManager: scanLogManagingSpy,
			scanLockManager: scanLockManagingSpy,
			configuration: .default
		)
		
		// Act
		sut.selectRisk = .high
		sut.confirmSetting()
		
		// Fish in Alert for OK action & trigger it:
		expect(self.sut.alert).toNot(beNil())
		sut.alert?.okAction?(UIAlertAction())
		
		// Assert
		expect(self.scanLockManagingSpy.invokedLockCount) == 1
	}
	
	func test_changingLevelOutsideOfTimeWindow_doesNotEnableLock() {
		// Arrange
		riskLevelManagingSpy.stubbedState = .low
		scanLogManagingSpy.stubbedDidWeScanQRsResult = false
		
		sut = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagingSpy,
			scanLogManager: scanLogManagingSpy,
			scanLockManager: scanLockManagingSpy,
			configuration: .default
		)
		
		// Act
		sut.selectRisk = .high
		sut.confirmSetting()
		
		// Fish in Alert for OK action & trigger it:
		expect(self.sut.alert).to(beNil())
		expect(self.scanLockManagingSpy.invokedLock) == false
	}
}
