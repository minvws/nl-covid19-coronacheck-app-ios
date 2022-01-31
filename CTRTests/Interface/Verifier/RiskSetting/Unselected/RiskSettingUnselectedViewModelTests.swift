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

final class RiskSettingUnselectedViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: RiskSettingUnselectedViewModel!
	
	/// The coordinator spy
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		riskLevelManagerSpy = RiskLevelManagerSpy()
		
		sut = RiskSettingUnselectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagerSpy
		)
	}
	
	// MARK: - Tests
	
	func test_bindings() {
		// Given
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifier_risksetting_firsttimeuse_title()
		expect(self.sut.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.primaryButtonTitle) == L.verifier_risksetting_confirmation_button()
		expect(self.sut.errorMessage) == L.verification_policy_selection_error_message()
		expect(self.sut.shouldDisplayNotSetError) == false
		expect(self.sut.selectVerificationPolicy).to(beNil())
	}
	
	func test_confirmSetting_whenUnselected_shouldDisplayError() {
		// When
		sut.confirmSetting()
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == true
		expect(self.riskLevelManagerSpy.invokedUpdate) == false
		expect(self.coordinatorSpy.invokedNavigateToVerifierWelcome) == false
	}
	
	func test_confirmSetting_whenSelected_shouldUpdateRiskSettingAndNavigateToStart() {
		// Given
		sut.selectVerificationPolicy = .policy1G
		
		// When
		sut.confirmSetting()
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == false
		expect(self.riskLevelManagerSpy.invokedUpdateParameters?.verificationPolicy) == .policy1G
		expect(self.coordinatorSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_selectRisk_shouldNotDisplayError() {
		// Given
		sut.confirmSetting()
		
		// When
		sut.selectVerificationPolicy = .policy3G
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == false
	}
}
