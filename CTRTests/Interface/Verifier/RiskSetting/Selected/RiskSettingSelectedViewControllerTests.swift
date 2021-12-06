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
	private var viewModel: RiskSettingSelectedViewModel!
	private var userSettingsSpy: UserSettingsSpy!
	
	var window = UIWindow()
	
	override  func setUp() {
		super.setUp()
		
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	func test_bindings() {
		// Given
		userSettingsSpy.stubbedScanRiskLevelValue = .low
		viewModel = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_risksetting_active_title()
		expect(self.sut.sceneView.header) == L.verifier_risksetting_firsttimeuse_header()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .low
	}
	
	func test_riskSetting_low() {
		// Given
		userSettingsSpy.stubbedScanRiskLevelValue = .low
		viewModel = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
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
		userSettingsSpy.stubbedScanRiskLevelValue = .high
		viewModel = RiskSettingSelectedViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingSelectedViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .high
		
		// Snapshot
		sut.assertImage()
	}
}
