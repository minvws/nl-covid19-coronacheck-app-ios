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

final class RiskSettingViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: RiskSettingViewController!
	
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: RiskSettingViewModel!
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
		viewModel = RiskSettingViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifierRisksettingTitle()
		expect(self.sut.sceneView.header) == L.verifierRisksettingHeaderMenuentry()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskTitle) == L.verifierRisksettingLowriskTitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskSubtitle) == L.verifierRisksettingLowriskSubtitle()
		expect(self.sut.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel) == "\(L.verifierRisksettingLowriskTitle()), \(L.verifierRisksettingLowriskSubtitle())"
		expect(self.sut.sceneView.riskSettingControlsView.highRiskTitle) == L.verifierRisksettingHighriskTitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskSubtitle) == L.verifierRisksettingHighriskSubtitle()
		expect(self.sut.sceneView.riskSettingControlsView.highRiskAccessibilityLabel) == "\(L.verifierRisksettingHighriskTitle()), \(L.verifierRisksettingHighriskSubtitle())"
		expect(self.sut.sceneView.moreButtonTitle) == L.verifierRisksettingReadmore()
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .low
	}
	
	func test_riskSetting_low() {
		// Given
		userSettingsSpy.stubbedScanRiskLevelValue = .low
		viewModel = RiskSettingViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingViewController(viewModel: viewModel)
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
		viewModel = RiskSettingViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
		sut = RiskSettingViewController(viewModel: viewModel)
		loadView()
		
		// When
		
		// Then
		expect(self.sut.sceneView.riskSettingControlsView.riskLevel) == .high
		
		// Snapshot
		sut.assertImage()
	}
}
