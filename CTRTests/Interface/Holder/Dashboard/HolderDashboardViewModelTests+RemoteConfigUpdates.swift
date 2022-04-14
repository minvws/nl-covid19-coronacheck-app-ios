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

	// MARK: - RemoteConfig changes

	func test_registersForRemoteConfigChanges_affectingStrippenRefresher() {

		// Arrange
		var sendUpdate: ((RemoteConfigManager.ConfigNotification) -> Void)?
		(environmentSpies.remoteConfigManagerSpy.stubbedObservatoryForUpdates, sendUpdate) = Observatory<RemoteConfigManager.ConfigNotification>.create()

		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		// Act
		sendUpdate?((RemoteConfiguration.default, Data(), URLResponse()))

		// Assert

		// First: during `.init`
		// Second: when it receives the `stubbedAppendUpdateObserverObserverResult` value above.
		expect(self.strippenRefresherSpy.invokedLoadCount) == 2
	}

	func test_configIsAlmostOutOfDate() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBanner = true
		var sendConfigReload: ((Result<RemoteConfigManager.ConfigNotification, ServerError>) -> Void)?
		(environmentSpies.remoteConfigManagerSpy.stubbedObservatoryForReloads, sendConfigReload) = Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>.create()

		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		sendConfigReload?(.success((RemoteConfiguration.default, Data(), URLResponse())))
		
		// Assert
		expect(self.sut.domesticCards[1]).to(beConfigurationAlmostOutOfDateCard())
		expect(self.sut.internationalCards[1]).to(beConfigurationAlmostOutOfDateCard())

		// only during .init
		expect(self.configurationNotificationManagerSpy.invokedShouldShowAlmostOutOfDateBannerGetterCount) == 2
	}

	func test_configIsAlmostOutOfDate_userTappedOnCard_domesticTab() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBanner = true
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

		// Act
		if case let .configAlmostOutOfDate(_, _, action) = sut.domesticCards[1] {
			action()
		}

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfig) == true
	}

	func test_configIsAlmostOutOfDate_userTappedOnCard_internationalTab() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBanner = true
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		// Act
		if case let .configAlmostOutOfDate(_, _, action) = sut.domesticCards[1] {
			action()
		}

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfig) == true
	}
	
	func test_recommendUpdate_recommendedVersion_higherActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.2.0"

		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, appVersion: "1.1.0")

		// Assert
		expect(self.sut.domesticCards[1]).toEventually(beRecommendedUpdateCard())
	}
	
	func test_recommendUpdate_recommendedVersion_lowerActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.0"
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, appVersion: "1.1.0")
		
		// Assert
		expect(self.sut.domesticCards[2]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_recommendUpdate_recommendedVersion_equalActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.1.0"
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, appVersion: "1.1.0")
		
		// Assert
		expect(self.sut.domesticCards[2]).toEventually(beEmptyStatePlaceholderImage())
	}
}
