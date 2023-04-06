/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import CoreData
import Shared
import TestingShared
import Persistence
@testable import Models
@testable import Managers
@testable import Resources

extension HolderDashboardViewModelTests {
	
//	// MARK: - Zero G
//	
//	// Note: `activeDisclosurePolicies: []` means 0G mode
//	
//	func test_zeroG_initialState_hasCorrectValues() {
//		
//		// Act
//		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
//
//		// Assert
//		expect(self.sut.shouldShowTabBar.value) == false
//		expect(self.sut.shouldShowOnlyInternationalPane.value) == true
//		
//		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
//		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
//			expect(message) == L.holder_dashboard_emptyState_international_0G_message()
//			expect(buttonTitle) == L.holder_dashboard_international_0G_action_certificateNeeded()
//		}))
//		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
//			expect(title) == L.holder_dashboard_noDomesticCertificatesBanner_0G_title()
//			expect(buttonText) == L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid()
//		}))
//		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
//	}
//	
//	func test_datasourceupdate_tripleCurrentlyValidDomesticButViewingInternationalTab_zeroG_shouldShowEmptyState() {
//		// Arrange
//		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [])
//		let qrCards = [
//			HolderDashboardViewModel.QRCard(
//				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
//				greencards: [.init(id: sampleGreencardObjectID, origins: [
//					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
//					.validOneHourAgo_test_expires23HoursFromNow(),
//					.validOneHourAgo_recovery_expires300DaysFromNow()
//				])],
//				shouldShowErrorBeneathCard: false,
//				evaluateEnabledState: { _ in true }
//			)
//		]
//		
//		// Act
//		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])
//		
//		// Assert
//		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
//		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
//		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
//			expect(title) == L.holder_dashboard_noDomesticCertificatesBanner_0G_title()
//			expect(buttonText) == L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid()
//		}))
//		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
//	}
//	
//	func test_datasourceupdate_domesticExpiredButOnInternationalTab_zeroG_shouldShowEmptyState() {
//		
//		// Arrange
//		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [])
//		
//		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
//			.init(region: .domestic, type: .recovery),
//			.init(region: .domestic, type: .test),
//			.init(region: .domestic, type: .vaccination)
//		]
//		
//		// Act
//		qrCardDatasourceSpy.invokedDidUpdate?([], expiredCards)
//		
//		// Assert
//		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
//		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
//		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
//			expect(title) == L.holder_dashboard_noDomesticCertificatesBanner_0G_title()
//			expect(buttonText) == L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid()
//		}))
//		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
//	}
//	
//	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccination_0G() {
//		
//		// Arrange
//		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [])
//		
//		let vaccineGreenCardID = NSManagedObjectID()
//		let testGreenCardID = NSManagedObjectID()
//		let recoveryGreenCardID = NSManagedObjectID()
//		
//		let qrCards = [
//			HolderDashboardViewModel.QRCard(
//				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
//				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
//				shouldShowErrorBeneathCard: false,
//				evaluateEnabledState: { _ in true }
//			),
//			HolderDashboardViewModel.QRCard(
//				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
//				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
//				shouldShowErrorBeneathCard: false,
//				evaluateEnabledState: { _ in true }
//			),
//			HolderDashboardViewModel.QRCard(
//				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
//				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
//				shouldShowErrorBeneathCard: false,
//				evaluateEnabledState: { _ in true }
//			)
//		]
//		
//		// Act
//		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])
//		
//		// Assert
//		expect(self.sut.internationalCards.value).toEventually(haveCount(6))
//		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
//			expect(message) == L.holder_dashboard_filledState_international_0G_message()
//			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
//		}))
//		
//		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
//		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
//			// check isLoading
//			expect(isLoading) == false
//			expect(title) == L.general_vaccinationcertificate_0G()
//			
//			let nowValidityTexts = validityTextEvaluator(now)
//			expect(nowValidityTexts.count) == 1
//			expect(nowValidityTexts[0].lines.count) == 2
//			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + ":"
//			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"
//			
//			expect(expiryCountdownEvaluator?(now)) == nil
//		}))
//		
//		expect(self.sut.internationalCards.value[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
//			// check isLoading
//			expect(isLoading) == false
//			expect(title) == L.general_recoverycertificate_0G()
//			
//			let nowValidityTexts = validityTextEvaluator(now)
//			expect(nowValidityTexts.count) == 1
//			expect(nowValidityTexts[0].lines.count) == 1
//			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
//			
//			expect(expiryCountdownEvaluator?(now)) == nil
//		}))
//		
//		expect(self.sut.internationalCards.value[4]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
//			// check isLoading
//			expect(isLoading) == false
//			expect(title) == L.general_testcertificate_0G()
//			
//			let nowValidityTexts = validityTextEvaluator(now)
//			expect(nowValidityTexts.count) == 1
//			expect(nowValidityTexts[0].lines.count) == 2
//			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
//			expect(nowValidityTexts[0].lines[1]) == "geldig tot donderdag 15 juli 16:02"
//			
//			expect(expiryCountdownEvaluator?(now)) == nil
//		}))
//		expect(self.sut.internationalCards.value[5]).toEventually(beAddCertificateCard())
//	}
}
