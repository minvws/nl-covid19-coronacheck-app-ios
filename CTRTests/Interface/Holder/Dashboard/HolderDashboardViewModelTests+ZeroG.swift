/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import CoreData

extension HolderDashboardViewModelTests {
	
	// MARK: - Zero G
	
	func test_zeroG_initialState_hasCorrectValues() {
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])

		// Assert
		expect(self.sut.shouldShowTabBar) == false
		expect(self.sut.shouldShowOnlyInternationalPane) == true
	}
	
	func test_zeroG_from1G_mutatesValuesCorrectly_viaViewWillAppear() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		expect(self.sut.shouldShowTabBar) == true
		expect(self.sut.shouldShowOnlyInternationalPane) == false

		// Act
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = true
		sut.viewWillAppear()

		// Assert
		expect(self.sut.shouldShowTabBar).toEventually(beFalse())
		expect(self.sut.shouldShowOnlyInternationalPane).toEventually(beTrue())
	}
	
	func test_zeroG_from1G_mutatesValuesCorrectly_viaUserDefaults() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		expect(self.sut.shouldShowTabBar) == true
		expect(self.sut.shouldShowOnlyInternationalPane) == false
		
		// Act
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = true
		sut.userDefaultsDidChange()

		// Assert
		expect(self.sut.shouldShowTabBar).toEventually(beFalse())
		expect(self.sut.shouldShowOnlyInternationalPane).toEventually(beTrue())
	}
}
