/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import TestingShared
import ReusableViews

class ConfigurationNotificationManagerTests: XCTestCase {

	/// Subject under test
	var sut: ConfigurationNotificationManager!

	private var userSettingsSpy: UserSettingsSpy!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	private var notificationCenterSpy: NotificationCenterSpy!
	
	override func setUp() {
		super.setUp()

		let spies = setupEnvironmentSpies()
		userSettingsSpy = spies.userSettingsSpy
		remoteConfigManagerSpy = spies.remoteConfigManagerSpy
		notificationCenterSpy = NotificationCenterSpy()
		notificationCenterSpy.stubbedAddObserverForNameResult = NSObject()
	}

	override func tearDown() {

		super.tearDown()
	}

	func test_shouldShowAlmostOutOfDateBanner_noConfigFetchedTimeStamp() {

		// Given
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		
		// When
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy
		)
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
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy
		)
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
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy
		)
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
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy
		)
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
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy
		)
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
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy
		)
		let shouldShowAlmostOutOfDateBanner = sut.shouldShowAlmostOutOfDateBanner

		// Then
		expect(shouldShowAlmostOutOfDateBanner) == true
	}
	
	func test_cancelsTimerWhenAppIsBackgrounded() throws {
		
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval((3600 - 59) * seconds * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		let timerSpy = TimerSpy()
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy,
			vendTimer: { interval, action in
				return timerSpy
			}
		)
		expect(timerSpy.invokedInvalidate) == false
		
		// Act
		// Go fishing for the Background Notification registered observer:
		let backgroundNotification = try XCTUnwrap(notificationCenterSpy.invokedAddObserverForNameParametersList.first(where: {
			$0.name == UIApplication.didEnterBackgroundNotification
		}))

		// Act
		// Trigger the background observer block:
		backgroundNotification.block(Notification(name: UIApplication.didEnterBackgroundNotification, object: nil, userInfo: nil))

		// Assert
		expect(timerSpy.invokedInvalidate).toEventually(beTrue())
	}
	
	func test_withinAlmostExpiredWindow_triggersObservatoryWhenForegrounding() throws {
		
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval((3600 - 59) * seconds * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		let observerVCR: ObserverCallbackRecorder<Bool> = ObserverCallbackRecorder()
		let timerSpy = TimerSpy()
		
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy,
			vendTimer: { interval, action in
				return timerSpy
			}
		)
		_ = sut.almostOutOfDateObservatory.append(observer: observerVCR.recordEvents)
		
		// Act
		// Go fishing for the Foreground Notification registered observer:
		let foregroundingNotification = try XCTUnwrap(notificationCenterSpy.invokedAddObserverForNameParametersList.first(where: {
			$0.name == UIApplication.willEnterForegroundNotification
		}))

		// Act
		// Trigger the foreground observer block:
		foregroundingNotification.block(Notification(name: UIApplication.willEnterForegroundNotification, object: nil, userInfo: nil))

		// Assert
		expect(observerVCR.values).toEventually(haveCount(1))
		expect(observerVCR.values[0]) == true
	}
	
	func test_outsideAlmostExpiredWindow_doesNotTriggerObservatoryWhenForegrounding() throws {
		
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(10 * seconds * ago).timeIntervalSince1970
		var configuration = RemoteConfiguration.default
		configuration.configAlmostOutOfDateWarningSeconds = 60
		configuration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration = configuration

		let observerVCR: ObserverCallbackRecorder<Bool> = ObserverCallbackRecorder()
		let timerSpy = TimerSpy()
		
		sut = ConfigurationNotificationManager(
			userSettings: userSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			now: { now },
			notificationCenter: notificationCenterSpy,
			vendTimer: { interval, action in
				return timerSpy
			}
		)
		_ = sut.almostOutOfDateObservatory.append(observer: observerVCR.recordEvents)
		
		// Act
		// Go fishing for the Foreground Notification registered observer:
		let foregroundingNotification = try XCTUnwrap(notificationCenterSpy.invokedAddObserverForNameParametersList.first(where: {
			$0.name == UIApplication.willEnterForegroundNotification
		}))

		// Act
		// Trigger the foreground observer block:
		foregroundingNotification.block(Notification(name: UIApplication.willEnterForegroundNotification, object: nil, userInfo: nil))

		// Assert
		expect(observerVCR.values).toEventually(beEmpty())
	}
}
