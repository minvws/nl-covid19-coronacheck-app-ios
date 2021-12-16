/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR
import XCTest
import Nimble

class GreenCardLoaderTests: XCTestCase {
	var userSettingsSpy: UserSettingsSpy!
	var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {
		super.setUp()

		userSettingsSpy = UserSettingsSpy()
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
	}

	func test_earlyExitIfLaunchDateNotReached() {
		// Arrange
		remoteConfigManagerSpy.stubbedStoredConfiguration = {
			var config: RemoteConfiguration = .default
			config.recoveryGreencardRevisedValidityLaunchDate = now.addingTimeInterval(1 * hour * fromNow)
			return config
		}()

		// Act
		GreenCardLoader.temporary___updateRecoveryExtensionValidityFlags(
			userSettings: userSettingsSpy, remoteConfigManager: remoteConfigManagerSpy, now: { now }
		)

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == false
	}

	func test_ifShouldCheckIsStillTrue_setFalse_exit() {
		// Arrange
		remoteConfigManagerSpy.stubbedStoredConfiguration = {
			var config: RemoteConfiguration = .default
			config.recoveryGreencardRevisedValidityLaunchDate = now.addingTimeInterval(yesterday)
			return config
		}()

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = true

		// Act
		GreenCardLoader.temporary___updateRecoveryExtensionValidityFlags(
			userSettings: userSettingsSpy, remoteConfigManager: remoteConfigManagerSpy, now: { now }
		)

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidity) == false

		// test that we do not continue
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCardGetter) == false
	}

	func test_ifShouldShowRecoveryValidityExtensionCard_falseAllFlags() {
		// Arrange
		remoteConfigManagerSpy.stubbedStoredConfiguration = {
			var config: RemoteConfiguration = .default
			config.recoveryGreencardRevisedValidityLaunchDate = now.addingTimeInterval(yesterday)
			return config
		}()

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = false
		userSettingsSpy.stubbedHasDismissedRecoveryValidityExtensionCompletionCard = true
		userSettingsSpy.stubbedShouldShowRecoveryValidityExtensionCard = true
		userSettingsSpy.stubbedShouldShowRecoveryValidityReinstationCard = false

		// Act
		GreenCardLoader.temporary___updateRecoveryExtensionValidityFlags(
			userSettings: userSettingsSpy, remoteConfigManager: remoteConfigManagerSpy, now: { now }
		)

		// Assert
		expect(self.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidityGetter) == true

		expect(self.userSettingsSpy.invokedHasDismissedRecoveryValidityExtensionCompletionCard) == false
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCard) == false
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCard) == false
	}

	func test_ifShouldShowRecoveryValidityReinstationCard_falseAllFlags() {
		// Arrange
		remoteConfigManagerSpy.stubbedStoredConfiguration = {
			var config: RemoteConfiguration = .default
			config.recoveryGreencardRevisedValidityLaunchDate = now.addingTimeInterval(yesterday)
			return config
		}()

		userSettingsSpy.stubbedShouldCheckRecoveryGreenCardRevisedValidity = false
		userSettingsSpy.stubbedHasDismissedRecoveryValidityExtensionCompletionCard = true
		userSettingsSpy.stubbedShouldShowRecoveryValidityExtensionCard = false
		userSettingsSpy.stubbedShouldShowRecoveryValidityReinstationCard = true

		// Act
		GreenCardLoader.temporary___updateRecoveryExtensionValidityFlags(
			userSettings: userSettingsSpy, remoteConfigManager: remoteConfigManagerSpy, now: { now }
		)

		// Assert
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCardGetter) == true

		expect(self.userSettingsSpy.invokedHasDismissedRecoveryValidityReinstationCompletionCard) == false
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityExtensionCard) == false
		expect(self.userSettingsSpy.invokedShouldShowRecoveryValidityReinstationCard) == false
	}
}
