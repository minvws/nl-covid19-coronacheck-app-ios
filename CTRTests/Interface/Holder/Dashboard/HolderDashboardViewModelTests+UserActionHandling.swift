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
@testable import Models
@testable import Managers
@testable import Resources

extension HolderDashboardViewModelTests {
	
	func test_openURL_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false

		// Act
		sut.openUrl(URL(fileURLWithPath: ""))

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_addCertificateFooterTapped_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
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
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapConfigAlmostOutOfDateCTA()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfigCount) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfigParameters?.validUntil) == "15 juli 18:02"
	}
	
	func test_actionhandling_didTapDeviceHasClockDeviationMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapDeviceHasClockDeviationMoreInfo()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviationCount) == 1
	}
	
	func test_actionhandling_didTapShowQR() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		let value = NSManagedObjectID()
		sut.didTapShowQR(greenCardObjectIDs: [value])
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.count) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === value
	}
	
	func test_actionhandling_didTapRetryLoadQRCards() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapRetryLoadQRCards()
		
		// Assert
		expect(self.strippenRefresherSpy.invokedLoadCount) == 2
	}
	
	func test_actionhandling_didTapRecommendedUpdate_noUrl() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapRecommendedUpdate()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
	}
	
	func test_actionhandling_didTapRecommendedUpdate() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = URL(string: "https://apple.com")
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapRecommendedUpdate()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_actionhandling_disclosurePolicyInformationCard_0g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
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
			
			expect(self.environmentSpies.userSettingsSpy.invokedHasDismissedZeroGPolicy) == nil
			didTapClose()
			expect(self.environmentSpies.userSettingsSpy.invokedHasDismissedZeroGPolicy) == true
		}))
		expect(self.sut.internationalCards.value[2]).to(beEmptyStatePlaceholderImage())
	}
}
