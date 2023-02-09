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

extension HolderDashboardViewModelTests {
	
	func test_openURL_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false

		// Act
		sut.openUrl(URL(fileURLWithPath: ""))

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_addCertificateFooterTapped_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAQR) == false

		// Act
		sut.addCertificateFooterTapped()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAQR) == true
	}
	
	// MARK: - HolderDashboardCardUserActionHandling callbacks
	
	func test_actionhandling_didTapConfigAlmostOutOfDateCTA() {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sut.didTapConfigAlmostOutOfDateCTA()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfigCount) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfigParameters?.validUntil) == "15 juli 18:02"
	}
	
	func test_actionhandling_didTapCloseExpiredQR() {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let expiredRecovery = HolderDashboardViewModel.ExpiredQR(region: .domestic, type: .recovery)
		let expiredTest = HolderDashboardViewModel.ExpiredQR(region: .domestic, type: .test)
		
		// Act & Assert
		qrCardDatasourceSpy.invokedDidUpdate?([], [expiredRecovery, expiredTest])
		
		expect(self.sut.domesticCards.value).toEventually(haveCount(4))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[1]).toEventually(beExpiredQRCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beExpiredQRCard())
		
		// Close first expired QR:
		sut.didTapCloseExpiredQR(expiredQR: expiredRecovery)
		
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[1]).toEventually(beExpiredQRCard(test: { title, _ in
			// The expired test card should remain:
			expect(title) == L.holder_dashboard_originExpiredBanner_domesticTest_title()
		}))
		
		// Close second expired QR:
		sut.didTapCloseExpiredQR(expiredQR: expiredTest)
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_actionhandling_didTapOriginNotValidInThisRegionMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapOriginNotValidInThisRegionMoreInfo(originType: .vaccination, validityRegion: .europeanUnion)
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRCount) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.originType) == .vaccination
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.currentRegion) == .europeanUnion
	}
	
	func test_actionhandling_didTapDeviceHasClockDeviationMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sut.didTapDeviceHasClockDeviationMoreInfo()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviationCount) == 1
	}
	
	func test_actionhandling_didTapShowQR() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		let value = NSManagedObjectID()
		sut.didTapShowQR(greenCardObjectIDs: [value], disclosurePolicy: DisclosurePolicy.policy3G)
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.count) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === value
	}
	
	func test_actionhandling_didTapRetryLoadQRCards() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sut.didTapRetryLoadQRCards()
		
		// Assert
		expect(self.strippenRefresherSpy.invokedLoadCount) == 2
	}
	
	func test_actionhandling_didTapRecommendedUpdate_noUrl() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sut.didTapRecommendedUpdate()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
	}
	
	func test_actionhandling_didTapRecommendedUpdate() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = URL(string: "https://apple.com")
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sut.didTapRecommendedUpdate()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_actionhandling_didTapCompleteYourVaccinationAssessmentMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sut.didTapCompleteYourVaccinationAssessmentMoreInfo()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutCompletingVaccinationAssessment) == true
	}
	
	func test_actionhandling_didTapVaccinationAssessmentInvalidOutsideNLMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapVaccinationAssessmentInvalidOutsideNLMoreInfo()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL) == true
	}
	
	func test_actionhandling_disclosurePolicyInformationCard_3g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], [])
		
		// Assert
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, didTapCallToAction, didTapClose in
			
			// Test `didTapCallToAction`
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
			didTapCallToAction()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_dashboard_only3GaccessBanner_link()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.inApp) == true
			
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == nil
			self.environmentSpies.userSettingsSpy.stubbedLastDismissedDisclosurePolicy = [.policy3G]
			didTapClose()
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == [.policy3G]
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beEmptyStatePlaceholderImage())
		
		expect(self.sut.internationalCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).to(beEmptyStatePlaceholderImage())
	}
	
	func test_actionhandling_disclosurePolicyInformationCard_1g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		
		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], [])
		
		// Assert
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, didTapCallToAction, didTapClose in
			
			// Test `didTapCallToAction`
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
			didTapCallToAction()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_dashboard_only1GaccessBanner_link()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.inApp) == true
			
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == nil
			self.environmentSpies.userSettingsSpy.stubbedLastDismissedDisclosurePolicy = [.policy1G]
			didTapClose()
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == [.policy1G]
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beEmptyStatePlaceholderImage())
		
		expect(self.sut.internationalCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).to(beEmptyStatePlaceholderImage())
	}
	
	func test_actionhandling_disclosurePolicyInformationCard_1g3g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G, .policy3G])
		
		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], [])
		
		// Assert
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, didTapCallToAction, didTapClose in
			
			// Test `didTapCallToAction`
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
			didTapCallToAction()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_dashboard_3Gand1GaccessBanner_link()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.inApp) == true
			
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == nil
			self.environmentSpies.userSettingsSpy.stubbedLastDismissedDisclosurePolicy = [.policy1G, .policy3G]
			didTapClose()
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == [.policy1G, .policy3G]
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beEmptyStatePlaceholderImage())
		
		expect(self.sut.internationalCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).to(beEmptyStatePlaceholderImage())
	}
	
	func test_actionhandling_disclosurePolicyInformationCard_0g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], [])
		
		// Assert
		expect(self.sut.internationalCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, didTapCallToAction, didTapClose in
			
			expect(title) == L.holder_dashboard_noDomesticCertificatesBanner_0G_title()
			expect(buttonText) == L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid()
			
			// Test `didTapCallToAction`
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
			didTapCallToAction()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_dashboard_noDomesticCertificatesBanner_url()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.inApp) == true
			
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == nil
			expect(self.environmentSpies.userSettingsSpy.invokedHasDismissedZeroGPolicy) == nil
			self.environmentSpies.userSettingsSpy.stubbedLastDismissedDisclosurePolicy = []
			didTapClose()
			expect(self.environmentSpies.userSettingsSpy.invokedLastDismissedDisclosurePolicy) == []
			expect(self.environmentSpies.userSettingsSpy.invokedHasDismissedZeroGPolicy) == true
		}))
		expect(self.sut.internationalCards.value[2]).to(beEmptyStatePlaceholderImage())
	}
}
