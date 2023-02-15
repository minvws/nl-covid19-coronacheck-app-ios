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
import Shared
import TestingShared
@testable import Models
@testable import Managers

final class RiskSettingSelectedViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: RiskSettingSelectedViewController!
	
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	private var viewModel: RiskSettingSelectedViewModel!
	
	var window = UIWindow()
	
	override  func setUp() {
		super.setUp()
		
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	func test_bindings() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_risksetting_active_title()
		expect(self.sut.sceneView.header) == nil
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifier_risksetting_subtitle_3G()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)), \(L.verifier_risksetting_subtitle_3G())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifier_risksetting_subtitle_1G()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)), \(L.verifier_risksetting_subtitle_1G())"
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy3G
	}
	
	func test_riskSetting_low() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
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
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.verificationPolicy) == .policy1G
		
		// Snapshot
		sut.assertImage()
	}

	func test_warning() {
		// Given
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()

		// When

		// Then
		expect(self.sut.sceneView.header) == L.verifier_risksetting_active_lock_warning_header(5)

		// Snapshot
		sut.assertImage()
	}
	
	func test_warningHidden() {
		// Given
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G

		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()

		// When

		// Then
		expect(self.sut.sceneView.header) == nil

		// Snapshot
		sut.assertImage()
	}
}
