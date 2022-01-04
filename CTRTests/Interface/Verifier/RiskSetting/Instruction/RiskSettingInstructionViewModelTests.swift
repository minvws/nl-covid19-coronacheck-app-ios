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

final class RiskSettingInstructionViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: RiskSettingInstructionViewModel!
	
	/// The coordinator spy
	private var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	
	override func setUp() {
		super.setUp()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
		riskLevelManagerSpy = RiskLevelManagerSpy()
		riskLevelManagerSpy.stubbedState = .low
		
		sut = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagerSpy
		)
	}
	
	// MARK: - Tests
	
	func test_showReadMore_shouldInvokeCoordinatorOpenUrl() {
		// Given
		
		// When
		sut.showReadMore()
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifier_risksetting_readmore_url()
	}
	
	func test_bindings() {
		// Given
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifier_risksetting_firsttimeuse_title()
		expect(self.sut.header) == L.verifier_risksetting_firsttimeuse_header()
		expect(self.sut.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.moreButtonTitle) == L.verifier_risksetting_readmore()
		expect(self.sut.primaryButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
		expect(self.sut.errorMessage) == L.verification_policy_selection_error_message()
		expect(self.sut.shouldDisplayNotSetError) == false
		expect(self.sut.riskLevel) == .low
	}
	
	func test_startScanner_shouldInvokeUserDidCompletePages() {
		// Given
		
		// When
		sut.startScanner()
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == false
		expect(self.riskLevelManagerSpy.invokedUpdateParameters?.riskLevel) == .low
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
	}
	
	func test_startScanner_whenUnselected_shouldDisplayError() {
		// Given
		riskLevelManagerSpy.stubbedState = nil
		sut = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagerSpy
		)
		
		// When
		sut.startScanner()
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == true
		expect(self.riskLevelManagerSpy.invokedUpdate) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
	}
}
