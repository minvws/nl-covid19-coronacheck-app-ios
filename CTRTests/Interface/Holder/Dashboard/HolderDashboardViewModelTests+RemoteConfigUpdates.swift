/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoreData
import CoronaCheckFoundation
import CoronaCheckTest
@testable import CTR

extension HolderDashboardViewModelTests {

	// MARK: - RemoteConfig changes

	func test_registersForRemoteConfigChanges_affectingStrippenRefresher() {

		// Arrange
		var sendUpdate: ((RemoteConfigManager.ConfigNotification) -> Void)?
		(environmentSpies.remoteConfigManagerSpy.stubbedObservatoryForUpdates, sendUpdate) = Observatory<RemoteConfigManager.ConfigNotification>.create()

		sut = vendSut()
		
		// Act
		sendUpdate?((RemoteConfiguration.default, Data(), URLResponse(), "hash"))

		// Assert

		// First: during `.init`
		// Second: when it receives the `stubbedAppendUpdateObserverObserverResult` value above.
		expect(self.strippenRefresherSpy.invokedLoadCount) == 2
	}

	func test_configIsAlmostOutOfDate_viaAccessor() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBanner = true

		// Act
		sut = vendSut()
		
		// Assert
		expect(self.sut.internationalCards.value[1]).to(beConfigurationAlmostOutOfDateCard())

		// only during .init
		expect(self.configurationNotificationManagerSpy.invokedShouldShowAlmostOutOfDateBannerGetterCount) == 1
	}
	
	func test_configIsAlmostOutOfDate_viaCallback() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBanner = false

		let (almostOutOfDateObservatory, almostOutOfDateObservatoryUpdates) = Observatory<Bool>.create()
		configurationNotificationManagerSpy.stubbedAlmostOutOfDateObservatory = almostOutOfDateObservatory

		// Act
		sut = vendSut()
		almostOutOfDateObservatoryUpdates(true)
		
		// Assert
		expect(self.sut.internationalCards.value[1]).to(beConfigurationAlmostOutOfDateCard())

		// only during .init
		expect(self.configurationNotificationManagerSpy.invokedShouldShowAlmostOutOfDateBannerGetterCount) == 1
	}

	func test_configIsAlmostOutOfDate_userTappedOnCard_internationalTab() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBanner = true
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut()

		// Act
		if case let .configAlmostOutOfDate(_, _, action) = sut.internationalCards.value[1] {
			action()
		}

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfig) == true
	}
	
	func test_recommendUpdate_recommendedVersion_higherActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.2.0"

		// Act
		sut = vendSut(appVersion: "1.1.0")

		// Assert
		expect(self.sut.internationalCards.value[1]).toEventually(beRecommendedUpdateCard())
	}
	
	func test_recommendUpdate_recommendedVersion_lowerActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.0"
		
		// Act
		sut = vendSut(appVersion: "1.1.0")
		
		// Assert
		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_recommendUpdate_recommendedVersion_equalActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.1.0"
		
		// Act
		sut = vendSut(appVersion: "1.1.0")
		
		// Assert
		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage())
	}
}
