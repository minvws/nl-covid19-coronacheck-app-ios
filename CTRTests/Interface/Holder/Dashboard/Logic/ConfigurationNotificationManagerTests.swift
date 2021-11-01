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

	override func setUp() {
		super.setUp()

		userSettingsSpy = UserSettingsSpy()
		sut = ConfigurationNotificationManager(userSettings: userSettingsSpy)
	}

	override func tearDown() {

		super.tearDown()
	}

	func test_shouldShowAlmostOutOfDateBanner_noConfigFetchedTimeStamp() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		let configuration = RemoteConfiguration.default

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner(
			now: now,
			remoteConfiguration: configuration
		)

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_noConfigAlmostOutOfDateWarningSeconds() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = nil

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner(
			now: now,
			remoteConfiguration: configuration
		)

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsStillUpToDate() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner(
			now: now,
			remoteConfiguration: configuration
		)

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == false
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsAlmostOutOfDate() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(2 * minutes * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner(
			now: now,
			remoteConfiguration: configuration
		)

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == true
	}

	func test_shouldShowAlmostOutOfDateBanner_configIsOutOfDate() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(61 * minutes * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600

		// When
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner(
			now: now,
			remoteConfiguration: configuration
		)

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == true
	}
}
