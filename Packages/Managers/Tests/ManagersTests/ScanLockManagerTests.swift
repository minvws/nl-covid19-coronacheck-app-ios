/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import TestingShared
// @testable import ReusableViews
@testable import Managers
@testable import Shared

class ScanLockManagerTests: XCTestCase {

	private var sut: ScanLockManager!
	private var notificationCenterSpy: NotificationCenterSpy!
	private var secureUserSettingsSpy: SecureUserSettingsSpy!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	private var observerVCR: ObserverCallbackRecorder<ScanLockManager.State>!
	
	override func setUp() {

		super.setUp()
		
		notificationCenterSpy = NotificationCenterSpy()
		notificationCenterSpy.stubbedAddObserverForNameResult = NSObject()
		
		secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedScanLockUntil = .distantPast
		
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		remoteConfigManagerSpy.stubbedStoredConfiguration.scanLockSeconds = 300
		remoteConfigManagerSpy.stubbedStoredConfiguration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration.configMinimumIntervalSeconds = 60

		observerVCR = ObserverCallbackRecorder()
	}
	
	func test_withNoPreviousTimer_isInitiallyUnlocked() {
		// Arrange
		sut = ScanLockManager(
			now: { now },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		
		// Act

		// Assert
		expect(self.sut.state) == .unlocked
		expect(self.observerVCR.values).to(beEmpty())
	}
	
	func test_withPreviousIncompleteTimer_isInitiallyLocked() {
		
		// Arrange
		let lockedUntil = now.addingTimeInterval(5 * minutes)
		secureUserSettingsSpy.stubbedScanLockUntil = lockedUntil
		
		// Act
		sut = ScanLockManager(
			now: { now },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)

		// Assert
		expect(self.sut.state) == .locked(until: lockedUntil)
		expect(self.observerVCR.values).to(beEmpty())
	}
	
	func test_locking_doesUpdateKeychainAndNotify() {
		// Arrange
		sut = ScanLockManager(
			now: { now },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)

		// Act
		let lockDuration = TimeInterval(remoteConfigManagerSpy.stubbedStoredConfiguration.scanLockSeconds!)
		let lockUntil = now.addingTimeInterval(lockDuration)
		secureUserSettingsSpy.stubbedScanLockUntil = lockUntil
		sut.lock()

		// Assert
		expect(self.sut.state) == .locked(until: lockUntil)
		expect(self.secureUserSettingsSpy.invokedScanLockUntil) == lockUntil
		expect(self.observerVCR.values.count).toEventually(equal(1))
		expect(self.observerVCR.values.first).toEventually(equal(.locked(until: lockUntil)))
	}
	
	// Because you can't rely on a Timer when you're in the background,
	// so on coming back to the foreground you need to restart the timer correctly.
	func test_foregroundNotification_doesTriggerUnlock_updateKeychainAndNotify() throws {

		var localTime = now
		let lockuntil = localTime.addingTimeInterval(5 * second)
		secureUserSettingsSpy.stubbedScanLockUntil = lockuntil
		
		var timer1: TimerSpy?
		
		// Arrange
		sut = ScanLockManager(
			now: { localTime },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			vendTimer: { _, _ in
				guard timer1 == nil else {
					fail("Expected to vend one timer")
					return TimerSpy()
				}
				timer1 = TimerSpy()
				return timer1!
			}
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		expect(self.sut.state) == .locked(until: lockuntil)

		// Go fishing for the Foreground Notification observer:
		let foregroundNotification = try XCTUnwrap(notificationCenterSpy.invokedAddObserverForNameParametersList.first(where: {
			$0.name == UIApplication.willEnterForegroundNotification
		}))

		// Act
		// Jump into the future
		localTime = now.addingTimeInterval(10 * seconds)
		
		// Trigger the foreground observer block:
		foregroundNotification.block(Notification(name: UIApplication.willEnterForegroundNotification, object: nil, userInfo: nil))
		
		// Assert
		expect(self.sut.state).toEventually(equal(.unlocked))
		expect(self.observerVCR.values.count).toEventually(equal(1))
		expect(self.observerVCR.values.last).toEventually(equal(.unlocked))
		
		expect(timer1?.invokedInvalidate) == true
	}
	
	func test_foregroundNotification_doesTriggerNewTimerInstatiation() throws {

		let lockuntil = now.addingTimeInterval(300 * second)
		secureUserSettingsSpy.stubbedScanLockUntil = lockuntil

		var timer1: TimerSpy?
		var timer2: TimerSpy?

		// Arrange
		sut = ScanLockManager(
			now: { now },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			vendTimer: { _, _ in
				if timer1 == nil {
					timer1 = TimerSpy()
					return timer1!
				} else if timer2 == nil {
					timer2 = TimerSpy()
					return timer2!
				}
				fail("Expected to vend two timers")
				return TimerSpy()
			}
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		expect(self.sut.state) == .locked(until: lockuntil)

		// Go fishing for the Foreground Notification observer:
		let foregroundNotification = try XCTUnwrap(notificationCenterSpy.invokedAddObserverForNameParametersList.first(where: {
			$0.name == UIApplication.willEnterForegroundNotification
		}))

		// Act
		// Trigger the foreground observer block:
		foregroundNotification.block(Notification(name: UIApplication.willEnterForegroundNotification, object: nil, userInfo: nil))

		// Assert
		expect(self.sut.state).toEventually(equal(.locked(until: lockuntil)))
		expect(self.observerVCR.values.count).toEventually(equal(1))
		expect(self.observerVCR.values.last).toEventually(equal(.locked(until: lockuntil)))

		expect(timer1?.invokedInvalidate) == true
		expect(timer2?.invokedInvalidate) == false
	}
	
	func test_backgroundNotification_doesInvalidateTimers() throws {

		let lockuntil = now.addingTimeInterval(300 * second)
		secureUserSettingsSpy.stubbedScanLockUntil = lockuntil

		var timer1: TimerSpy?

		// Arrange
		sut = ScanLockManager(
			now: { now },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			vendTimer: { _, _ in
				guard timer1 == nil else {
					fail("Expected to vend one timer")
					return TimerSpy()
				}
				timer1 = TimerSpy()
				return timer1!
			}
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)
		expect(self.sut.state) == .locked(until: lockuntil)

		// Go fishing for the Background Notification registered observer:
		let backgroundNotification = try XCTUnwrap(notificationCenterSpy.invokedAddObserverForNameParametersList.first(where: {
			$0.name == UIApplication.didEnterBackgroundNotification
		}))

		// Act
		// Trigger the background observer block:
		backgroundNotification.block(Notification(name: UIApplication.didEnterBackgroundNotification, object: nil, userInfo: nil))

		// Assert
		expect(timer1?.invokedInvalidate) == true
	}
	
	func testWipePersistedDataClearsObserversAndResetsLock() {
		// Arrange
		let lockedUntil = now.addingTimeInterval(5 * minutes)
		secureUserSettingsSpy.stubbedScanLockUntil = lockedUntil
		
		sut = ScanLockManager(
			now: { now },
			notificationCenter: notificationCenterSpy,
			secureUserSettings: secureUserSettingsSpy,
			remoteConfigManager: remoteConfigManagerSpy
		)
		_ = sut.observatory.append(observer: observerVCR.recordEvents)

		// Act
		sut.wipePersistedData()
		
		// Assert
		expect(self.sut.state) == .unlocked
		expect(self.secureUserSettingsSpy.invokedScanLockUntil) == Date.distantPast
		
		// Observers receive no callback because no longer registered:
		sut.lock()
		
		expect(self.observerVCR.values.count).toEventually(equal(0))
	}
}
