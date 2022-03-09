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
	
	func test_datasourceupdate_tripleCurrentlyValidDomesticButViewingInternationalTab_zeroG_shouldShowEmptyState() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
			expect(title) == L.holder_dashboard_noDomesticCertificatesBanner_0G_title()
			expect(buttonText) == L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid()
		}))
		expect(self.sut.internationalCards[2]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_datasourceupdate_domesticExpiredButOnInternationalTab_zeroG_shouldShowEmptyState() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [])
		
		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery),
			.init(region: .domestic, type: .test),
			.init(region: .domestic, type: .vaccination)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
			expect(title) == L.holder_dashboard_noDomesticCertificatesBanner_0G_title()
			expect(buttonText) == L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid()
		}))
		expect(self.sut.internationalCards[2]).toEventually(beEmptyStatePlaceholderImage())
	}
}
