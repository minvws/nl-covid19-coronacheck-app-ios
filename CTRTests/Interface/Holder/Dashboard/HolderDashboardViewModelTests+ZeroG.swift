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
	
	// Note: `activeDisclosurePolicies: []` means 0G mode
	
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
	
	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccination_0G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [])
		
		let vaccineGreenCardID = NSManagedObjectID()
		let testGreenCardID = NSManagedObjectID()
		let recoveryGreenCardID = NSManagedObjectID()
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(7))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_vaccinationcertificate_0G()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		
		expect(self.sut.internationalCards[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_recoverycertificate_0G()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 1
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		
		expect(self.sut.internationalCards[4]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_testcertificate_0G()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot donderdag 15 juli 16:02"
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[5]).toEventually(beAddCertificateCard())
		expect(self.sut.internationalCards[6]).toEventually(beRecommendCoronaMelderCard())
	}
}
