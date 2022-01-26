/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble
import Rswift

final class RiskSettingUnselectedViewControllerTests: XCTestCase {

	/// Subject under test
	private var sut: RiskSettingUnselectedViewController!
	
	/// The coordinator spy
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	private var viewModel: RiskSettingUnselectedViewModel!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		riskLevelManagerSpy = RiskLevelManagerSpy()
		
		viewModel = RiskSettingUnselectedViewModel(
			coordinator: coordinatorSpy,
			riskLevelManager: riskLevelManagerSpy
		)
		sut = RiskSettingUnselectedViewController(viewModel: viewModel)
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	func test_bindings() {
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_risksetting_firsttimeuse_title()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy).to(beNil())
		
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifier_risksetting_confirmation_button()
		expect(self.sut.sceneView.errorMessage) == L.verification_policy_selection_error_message()
		expect(self.sut.sceneView.hasErrorState) == false
	}
	
	func test_errorState() {
		// Given
		viewModel.confirmSetting()
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.hasErrorState) == true
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_riskSetting_low() {
		// Given
		sut.sceneView.riskSettingControlsView.verificationPolicy = .policy3G
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy3G
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_riskSetting_high() {
		// Given
		sut.sceneView.riskSettingControlsView.verificationPolicy = .policy1G
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy1G
		
		// Snapshot
		sut.assertImage()
	}
}
