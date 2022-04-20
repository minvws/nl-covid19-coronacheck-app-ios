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
	
	// MARK: Datasource Updating
	
	func test_featureflag_shouldShowCoronaMelderRecommendation_enabled_emptystate() {
		
		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedShouldShowCoronaMelderRecommendationResult = true
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		datasourceSpy.invokedDidUpdate?([], [])
		
		// Assert
		
		expect(self.sut.domesticCards).toEventuallyNot(containElementSatisfying({ element in
			if case .recommendCoronaMelder = element { return true }
			return false
		}))
		
		expect(self.sut.internationalCards).toEventuallyNot(containElementSatisfying({ element in
			if case .recommendCoronaMelder = element { return true }
			return false
		}))
	}
	
	func test_featureflag_shouldShowCoronaMelderRecommendation_enabled_nonemptystate() {
		
		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedShouldShowCoronaMelderRecommendationResult = true
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		
		expect(self.sut.domesticCards).toEventually(containElementSatisfying({ element in
			if case .recommendCoronaMelder = element { return true }
			return false
		}))
		
		expect(self.sut.internationalCards).toEventuallyNot(containElementSatisfying({ element in
			if case .recommendCoronaMelder = element { return true }
			return false
		}))
	}
	
	func test_featureflag_shouldShowCoronaMelderRecommendation_disabled() {
		
		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedShouldShowCoronaMelderRecommendationResult = false
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		
		expect(self.sut.domesticCards).toEventuallyNot(containElementSatisfying({ element in
			if case .recommendCoronaMelder = element { return true }
			return false
		}))
		
		expect(self.sut.internationalCards).toEventuallyNot(containElementSatisfying({ element in
			if case .recommendCoronaMelder = element { return true }
			return false
		}))
	}
}
