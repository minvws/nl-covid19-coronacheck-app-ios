/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR
import Nimble

class ConfigurationNotificationManagerTests: XCTestCase {

	/// Subject under test
	var sut: ConfigurationNotificationManager!

	private var userSettingsSpy: UserSettingsSpy!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {
		super.setUp()

		let spies = setupEnvironmentSpies()
		userSettingsSpy = spies.userSettingsSpy
		remoteConfigManagerSpy = spies.remoteConfigManagerSpy
		
		sut = ConfigurationNotificationManager(userSettings: userSettingsSpy, remoteConfigManager: remoteConfigManagerSpy, now: { now })
	}

	override func tearDown() {

		super.tearDown()
	}

	func test_shouldShowAlmostOutOfDateBanner_noConfigFetchedTimeStamp() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_noConfigAlmostOutOfDateWarningSeconds() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = nil

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsStillUpToDate() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsAlmostOutOfDate_oldbehavior_should_not_show_banner() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(2 * minutes * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsAlmostOutOfDate() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval((3600 - 59) * seconds * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == true
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsOutOfDate() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(61 * minutes * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == true
	}
}
