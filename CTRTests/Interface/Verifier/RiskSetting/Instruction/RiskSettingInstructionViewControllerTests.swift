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

final class RiskSettingInstructionViewControllerTests: XCTestCase { // swiftlint:disable:this type_name
	
	// MARK: Subject under test
	private var sut: RiskSettingInstructionViewController!
	
	private var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var viewModel: RiskSettingInstructionViewModel!
	private var userSettingsSpy: UserSettingsSpy!
	
	var window = UIWindow()
	
	override  func setUp() {
		super.setUp()
		
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
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
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.title).to(beNil())
		expect(self.sut.sceneView.title) == L.verifier_risksetting_firsttimeuse_title()
		expect(self.sut.sceneView.header) == L.verifier_risksetting_firsttimeuse_header()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.sceneView.moreButtonTitle) == L.verifier_risksetting_readmore()
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .low
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_riskSetting_low() {
		// Given
		userSettingsSpy.stubbedScanRiskLevelValue = .low
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
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
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .high
		
		// Snapshot
		sut.assertImage()
	}
}
