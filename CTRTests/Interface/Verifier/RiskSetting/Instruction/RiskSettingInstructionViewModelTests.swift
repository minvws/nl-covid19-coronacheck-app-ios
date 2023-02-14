/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Shared
@testable import Models
@testable import Managers

final class RiskSettingInstructionViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: RiskSettingInstructionViewModel!
	
	/// The coordinator spy
	private var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		
		sut = RiskSettingInstructionViewModel(coordinator: coordinatorSpy)
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
		expect(self.sut.lowRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		expect(self.sut.lowRiskSubtitle) == L.verifier_risksetting_subtitle_3G()
		expect(self.sut.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)), \(L.verifier_risksetting_subtitle_3G())"
		expect(self.sut.highRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		expect(self.sut.highRiskSubtitle) == L.verifier_risksetting_subtitle_1G()
		expect(self.sut.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)), \(L.verifier_risksetting_subtitle_1G())"
		expect(self.sut.moreButtonTitle) == L.verifier_risksetting_readmore()
		expect(self.sut.primaryButtonTitle) == L.verifierScaninstructionsButtonStartscanning()
		expect(self.sut.errorMessage) == L.verification_policy_selection_error_message()
		expect(self.sut.shouldDisplayNotSetError) == false
		expect(self.sut.verificationPolicy) == .policy3G
	}
	
	func test_startScanner_shouldInvokeUserDidCompletePages() {
		// Given
		
		// When
		sut.startScanner()
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == false
		expect(self.environmentSpies.verificationPolicyManagerSpy.invokedUpdateParameters?.verificationPolicy) == .policy3G
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == true
	}
	
	func test_startScanner_whenUnselected_shouldDisplayError() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = RiskSettingInstructionViewModel(coordinator: coordinatorSpy)
		
		// When
		sut.startScanner()
		
		// Then
		expect(self.sut.shouldDisplayNotSetError) == true
		expect(self.environmentSpies.verificationPolicyManagerSpy.invokedUpdate) == false
		expect(self.coordinatorSpy.invokedUserDidCompletePages) == false
	}
}
