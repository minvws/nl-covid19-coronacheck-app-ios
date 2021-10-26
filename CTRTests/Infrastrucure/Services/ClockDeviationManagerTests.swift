/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

class ClockDeviationManagerTests: XCTestCase {

	// MARK: - Setup
	var sut: ClockDeviationManager!
	var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {
		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy(now: { now }, userSettings: UserSettingsSpy())
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		remoteConfigManagerSpy.stubbedAppendReloadObserverResult = UUID()
		remoteConfigManagerSpy.stubbedAppendUpdateObserverResult = UUID()
		
		sut = ClockDeviationManager(
			remoteConfigManager: remoteConfigManagerSpy,
			currentSystemUptime: { 1 * 3600 },
			now: { now }
		)
	}

	// MARK: - Tests

	func test_initialState() {
		// Arrange

		// Act

		// Assert
		expect(self.sut.hasSignificantDeviation).to(beNil())
	}

	func test_updateWithServerDateString_withSignificantDeviation() {
		// Arrange

		// Act
		sut.update(serverHeaderDate: "Sat, 07 Aug 2021 12:12:57 GMT", ageHeader: nil)

		// Assert
		expect(self.sut.hasSignificantDeviation) == true
	}

	func test_updateWithServerDateString_withoutSignificantDeviation() {
		// Arrange

		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:30 GMT", ageHeader: nil)

		// Assert
		expect(self.sut.hasSignificantDeviation) == false
	}

	func test_updateWithServerDateString_withSignificantDeviation_withAgeHeader() {
		// Arrange

		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:00 GMT", ageHeader: "30")

		// Assert
		expect(self.sut.hasSignificantDeviation) == false
	}

	func test_deviationchange_notification() {
		// Arrange
		var receivedValue: Bool?
		_ = sut.appendDeviationChangeObserver { hasDeviation in
			receivedValue = hasDeviation
		}

		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:30 GMT", ageHeader: nil)

		// Assert
		expect(receivedValue) == false
	}

	func test_reactsToSystemDateChange() {
		// Arrange
		var receivedCount = 0
		_ = sut.appendDeviationChangeObserver { _ in
			receivedCount += 1
		}

		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:30 GMT", ageHeader: nil)
		expect(receivedCount) == 1

		NotificationCenter.default.post(name: .NSSystemClockDidChange, object: nil)

		// Assert
		expect(receivedCount).toEventually(equal(2))
	}
}
