/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble
import Rswift
import Shared
import TestingShared

final class RiskSettingInstructionViewControllerTests: XCTestCase { // swiftlint:disable:this type_name
	
	// MARK: Subject under test
	private var sut: RiskSettingInstructionViewController!
	
	private var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var viewModel: RiskSettingInstructionViewModel!
	private var environmentSpies: EnvironmentSpies!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	func test_bindings() {
		// Given
		
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		viewModel = RiskSettingInstructionViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.title) == nil
		expect(self.sut.sceneView.title) == L.verifier_risksetting_firsttimeuse_title()
		expect(self.sut.sceneView.header) == L.verifier_risksetting_firsttimeuse_header()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifier_risksetting_subtitle_3G()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)), \(L.verifier_risksetting_subtitle_3G())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifier_risksetting_subtitle_1G()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)), \(L.verifier_risksetting_subtitle_1G())"
		expect(self.sut.sceneView.moreButtonTitle) == L.verifier_risksetting_readmore()
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy3G
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifierScaninstructionsButtonStartscanning()
		expect(self.sut.sceneView.errorMessage) == L.verification_policy_selection_error_message()
		expect(self.sut.sceneView.hasErrorState) == false
	}
	
	func test_riskSetting_low() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		viewModel = RiskSettingInstructionViewModel(coordinator: coordinatorSpy)
		
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy3G
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_riskSetting_high() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy1G
		
		// Snapshot
		sut.assertImage()
	}
}
