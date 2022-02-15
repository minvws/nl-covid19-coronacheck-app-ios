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
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beCompleteYourVaccinationAssessmentCard(test: { message, buttonTitle, _ in
			expect(message) == L.holder_dashboard_visitorpassincompletebanner_title()
			expect(buttonTitle) == L.holder_dashboard_visitorpassincompletebanner_button_makecomplete()
		}))
	}
	
	func test_vaccinationassessment_domestic_shouldNotShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = false
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[2]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_vaccinationassessment_international_shouldShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = true
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beVaccinationAssessmentInvalidOutsideNLCard(test: { message, buttonTitle, _ in
			expect(message) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(buttonTitle) == L.general_readmore()
		}))
	}
	
	func test_vaccinationassessment_international_shouldNotShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = false
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}
}
