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
		environmentSpies.riskLevelManagerSpy.stubbedState = .low
		
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_risksetting_active_title()
		expect(self.sut.sceneView.header).to(beNil())
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.highPlusRiskTitle) == L.verifier_risksetting_2g_plus_title()
		expect(self.sut.sceneView.riskSettingControlsView.highPlusRiskSubtitle) == L.verifier_risksetting_2g_plus_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highPlusRiskAccessibilityLabel) == "\(L.verifier_risksetting_2g_plus_title()), \(L.verifier_risksetting_2g_plus_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .low
	}
	
	func test_riskSetting_low() {
		// Given
		environmentSpies.riskLevelManagerSpy.stubbedState = .low
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .low
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_riskSetting_high() {
		// Given
		environmentSpies.riskLevelManagerSpy.stubbedState = .high
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .high
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_riskSetting_highPlus() {
		// Given
		environmentSpies.riskLevelManagerSpy.stubbedState = .highPlus
		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .highPlus
		
		// Snapshot
		sut.assertImage()
	}

	func test_warning() {
		// Given
		environmentSpies.scanLogManagerSpy.stubbedDidWeScanQRsResult = true
		environmentSpies.riskLevelManagerSpy.stubbedState = .high
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
		environmentSpies.riskLevelManagerSpy.stubbedState = .low

		viewModel = RiskSettingSelectedViewModel(coordinator: coordinatorSpy)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()

		// When

		// Then
		expect(self.sut.sceneView.header).to(beNil())

		// Snapshot
		sut.assertImage()
	}
}
