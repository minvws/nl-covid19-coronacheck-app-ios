/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import CoreData
@testable import CTR
import Nimble
import Reachability

class RecoveryValidityExtensionManagerTests: XCTestCase {

	/// Subject under test
	var sut: RecoveryValidityExtensionManager!
	var userSettingsSpy: UserSettingsSpy!
	var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {
		super.setUp()

		userSettingsSpy = UserSettingsSpy()
		remoteConfigManagerSpy = RemoteConfigManagingSpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			networkManager: NetworkSpy()
		)

		remoteConfigManagerSpy.stubbedStoredConfiguration = {
			var config: RemoteConfiguration = .default
			config.recoveryGreencardRevisedValidityLaunchDate = now.addingTimeInterval(yesterday)
			return config
		}()
	}

	func test_noCallbackSet_doesNothing() {
		// Arrange
		var queriedRecoveryEvents = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				queriedRecoveryEvents = true
				return true
			},
			userHasUnexpiredRecoveryGreencards: { false },
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)

		// Act
		sut.reload()

		// Assert
		expect(queriedRecoveryEvents) == false
	}

	func test_launchDateNotReached_doesNothing() {
		// Arrange
		var queriedRecoveryEvents = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				queriedRecoveryEvents = true
				return true
			},
			userHasUnexpiredRecoveryGreencards: { false },
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)
		sut.bannerStateCallback = { _ in }

		remoteConfigManagerSpy.stubbedStoredConfiguration = {
			var config: RemoteConfiguration = .default
			config.recoveryGreencardRevisedValidityLaunchDate = now.addingTimeInterval(tomorrow)
			return config
		}()

		// Act
		sut.reload()

		// Assert
		expect(queriedRecoveryEvents) == false
	}

	func test_noRecoveryEvents_doesNothing() {
		// Arrange
		var queriedRecoveryEvents = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				queriedRecoveryEvents = true
				return false
			},
			userHasUnexpiredRecoveryGreencards: { false },
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)
		sut.bannerStateCallback = { _ in }

		// Act
		sut.reload()

		// Assert
		expect(queriedRecoveryEvents) == true
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == false
	}

	func test_hasRecoveryEvents_shouldCheckIsFalse_callsBack_nil() {
		// Arrange
		var invokedUserHasUnexpiredRecoveryGreencards = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				return true
			},
			userHasUnexpiredRecoveryGreencards: {
				invokedUserHasUnexpiredRecoveryGreencards = true
				return false
			},
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)

		// set non-nil value to see if it gets nilled
		var callbackValue: RecoveryValidityExtensionManager.BannerType? = .extensionDidComplete
		sut.bannerStateCallback = { val in callbackValue = val }

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = false

		// Act
		sut.reload()

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == true

		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCardGetter) == true
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCardGetter) == true
		expect(invokedUserHasUnexpiredRecoveryGreencards) == true

		expect(callbackValue).to(beNil())
	}

	func test_hasRecoveryEvents_shouldCheckIsTrue_withUnexpiredRecoveryGreencards() {

		// Arrange
		var invokedUserHasUnexpiredRecoveryGreencards = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				return true
			},
			userHasUnexpiredRecoveryGreencards: {
				invokedUserHasUnexpiredRecoveryGreencards = true
				return true
			},
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)

		// set non-nil value to see if it gets nilled
		var callbackValue: RecoveryValidityExtensionManager.BannerType? = .extensionDidComplete
		sut.bannerStateCallback = { val in callbackValue = val }

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = true

		userSettingsSpy.stubbedShouldShowRecoveryValidityExtensionCard = true
		userSettingsSpy.stubbedShouldShowRecoveryValidityReinstationCard = false
		// Act
		sut.reload()

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == true
		expect(invokedUserHasUnexpiredRecoveryGreencards) == true

		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCard) == true
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCard) == false
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidity) == false

		expect(callbackValue) == .extensionAvailable
	}

	func test_hasRecoveryEvents_shouldCheckIsTrue_withoutUnexpiredRecoveryGreencards() {

		// Arrange
		var invokedUserHasUnexpiredRecoveryGreencards = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				return true
			},
			userHasUnexpiredRecoveryGreencards: {
				invokedUserHasUnexpiredRecoveryGreencards = true
				return false
			},
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)

		// set non-nil value to see if it gets nilled
		var callbackValue: RecoveryValidityExtensionManager.BannerType? = .extensionDidComplete
		sut.bannerStateCallback = { val in callbackValue = val }

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = true

		userSettingsSpy.stubbedShouldShowRecoveryValidityExtensionCard = false
		userSettingsSpy.stubbedShouldShowRecoveryValidityReinstationCard = true
		// Act
		sut.reload()

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == true
		expect(invokedUserHasUnexpiredRecoveryGreencards) == true

		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCard) == false
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCard) == true
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidity) == false

		expect(callbackValue) == .reinstationAvailable
	}

	func test_hasRecoveryEvents_shouldCheckIsFalse_hasNotDismissedExtension() {

		// Arrange
		var invokedUserHasUnexpiredRecoveryGreencards = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				return true
			},
			userHasUnexpiredRecoveryGreencards: {
				invokedUserHasUnexpiredRecoveryGreencards = true
				return true
			},
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)

		// set non-nil value to see if it gets nilled
		var callbackValue: RecoveryValidityExtensionManager.BannerType? = .extensionDidComplete
		sut.bannerStateCallback = { val in callbackValue = val }

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = false
		userSettingsSpy.stubbedShouldShowRecoveryValidityExtensionCard = false
		userSettingsSpy.stubbedShouldShowRecoveryValidityReinstationCard = false
		userSettingsSpy.stubbedHasDismissedRecoveryValidityExtensionCard = false
		userSettingsSpy.stubbedHasDismissedRecoveryValidityReinstationCard = true

		// Act
		sut.reload()

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == true
		expect(invokedUserHasUnexpiredRecoveryGreencards) == true

		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCardGetter) == true
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCardGetter) == true

		expect(callbackValue) == .extensionDidComplete
	}

	func test_hasRecoveryEvents_shouldCheckIsFalse_hasNotDismissedReinstation() {

		// Arrange
		var invokedUserHasUnexpiredRecoveryGreencards = false
		sut = RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				return true
			},
			userHasUnexpiredRecoveryGreencards: {
				invokedUserHasUnexpiredRecoveryGreencards = true
				return true
			},
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now }
		)

		// set non-nil value to see if it gets nilled
		var callbackValue: RecoveryValidityExtensionManager.BannerType? = .extensionDidComplete
		sut.bannerStateCallback = { val in callbackValue = val }

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = false
		userSettingsSpy.stubbedShouldShowRecoveryValidityExtensionCard = false
		userSettingsSpy.stubbedShouldShowRecoveryValidityReinstationCard = false
		userSettingsSpy.stubbedHasDismissedRecoveryValidityExtensionCard = true
		userSettingsSpy.stubbedHasDismissedRecoveryValidityReinstationCard = false

		// Act
		sut.reload()

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == true
		expect(invokedUserHasUnexpiredRecoveryGreencards) == true

		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCardGetter) == true
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCardGetter) == true
		expect(self.userSettingsSpy.invokedHasDismissedRecoveryValidityReinstationCardGetter) == true

		expect(callbackValue) == .reinstationDidComplete
	}
}
