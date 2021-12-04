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

final class RiskSettingViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: RiskSettingViewModel!
	
	/// The coordinator spy
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var userSettingsSpy: UserSettingsSpy!
	
	override func setUp() {
		super.setUp()
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
		userSettingsSpy.stubbedScanRiskLevelValue = .low
		
		sut = RiskSettingViewModel(
			coordinator: coordinatorSpy,
			userSettings: userSettingsSpy
		)
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
		expect(self.sut.title) == L.verifier_risksetting_active_title()
		expect(self.sut.header) == L.verifier_risksetting_firsttimeuse_header()
		expect(self.sut.lowRiskTitle) == L.verifier_risksetting_lowrisk_title()
		expect(self.sut.lowRiskSubtitle) == L.verifier_risksetting_lowrisk_subtitle()
		expect(self.sut.lowRiskAccessibilityLabel) == "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		expect(self.sut.highRiskTitle) == L.verifier_risksetting_highrisk_title()
		expect(self.sut.highRiskSubtitle) == L.verifier_risksetting_highrisk_subtitle()
		expect(self.sut.highRiskAccessibilityLabel) == "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		expect(self.sut.moreButtonTitle) == L.verifier_risksetting_readmore()
		expect(self.sut.riskLevel) == .low
	}
	
	func test_selectRisk_shouldSetHighRisk() {
		// Given
		
		// When
		sut.selectRisk = .high
		
		// When
		expect(self.userSettingsSpy.invokedScanRiskLevelValue) == .high
	}
}
