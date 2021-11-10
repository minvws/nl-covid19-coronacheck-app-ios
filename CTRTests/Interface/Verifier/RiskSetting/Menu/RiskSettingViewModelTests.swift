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
		userSettingsSpy.stubbedScanRiskSettingValue = .low
		
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
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierRisksettingReadmoreUrl()
	}
	
	func test_bindings() {
		// Given
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifierRisksettingTitle()
		expect(self.sut.header) == L.verifierRisksettingHeaderMenuentry()
		expect(self.sut.lowRiskTitle) == L.verifierRisksettingLowriskTitle()
		expect(self.sut.lowRiskSubtitle) == L.verifierRisksettingLowriskSubtitle()
		expect(self.sut.highRiskTitle) == L.verifierRisksettingHighriskTitle()
		expect(self.sut.highRiskSubtitle) == L.verifierRisksettingHighriskSubtitle()
		expect(self.sut.moreButtonTitle) == L.verifierRisksettingReadmore()
		expect(self.sut.riskSetting) == .low
	}
}
