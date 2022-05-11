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
	
	// MARK: - Vaccination Assessment
	
	func test_vaccinationassessment_domestic_shouldShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = true
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(4))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[1]).toEventually(beCompleteYourVaccinationAssessmentCard(test: { message, buttonTitle, _ in
			expect(message) == L.holder_dashboard_visitorpassincompletebanner_title()
			expect(buttonTitle) == L.holder_dashboard_visitorpassincompletebanner_button_makecomplete()
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[3]).toEventually(beAddCertificateCard())
	}
	
	func test_vaccinationassessment_domestic_shouldNotShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = false
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_vaccinationassessment_international_shouldShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = true
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).toEventually(beVaccinationAssessmentInvalidOutsideNLCard(test: { message, buttonTitle, _ in
			expect(message) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(buttonTitle) == L.general_readmore()
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beAddCertificateCard())
	}
	
	func test_vaccinationassessment_international_shouldNotShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = false
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(2))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).toEventually(beEmptyStatePlaceholderImage())
	}
}
