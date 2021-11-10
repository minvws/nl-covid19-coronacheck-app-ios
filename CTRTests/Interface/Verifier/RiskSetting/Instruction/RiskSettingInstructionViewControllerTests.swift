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
		userSettingsSpy.stubbedScanRiskSettingValue = .low
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.title).to(beNil())
		expect(self.sut.sceneView.title) == L.verifierRisksettingTitleInstruction()
		expect(self.sut.sceneView.header) == L.verifierRisksettingHeaderInstruction()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifierRisksettingLowriskTitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifierRisksettingLowriskSubtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifierRisksettingHighriskTitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifierRisksettingHighriskSubtitle()
		expect(self.sut.sceneView.moreButtonTitle) == L.verifierRisksettingReadmore()
		expect(self.sut.sceneView.riskSettingControlsView.riskSetting) == .low
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_riskSetting_low() {
		// Given
		userSettingsSpy.stubbedScanRiskSettingValue = .low
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskSetting) == .low
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_riskSetting_high() {
		// Given
		userSettingsSpy.stubbedScanRiskSettingValue = .high
		viewModel = RiskSettingInstructionViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingInstructionViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskSetting) == .high
		
		// Snapshot
		sut.assertImage()
	}
}
