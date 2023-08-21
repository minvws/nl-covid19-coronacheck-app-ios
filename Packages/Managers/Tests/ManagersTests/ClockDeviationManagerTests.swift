/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import XCTest
import Nimble
@testable import Managers
@testable import Transport
@testable import Shared
import TestingShared

class ClockDeviationManagerTests: XCTestCase {
	
	// MARK: - Setup
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> ClockDeviationManager {
			
		let remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		(remoteConfigManagerSpy.stubbedObservatoryForReloads, _) = Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>.create()
		(remoteConfigManagerSpy.stubbedObservatoryForUpdates, _) = Observatory<RemoteConfigManager.ConfigNotification>.create()
		
		let sut = ClockDeviationManager(
			remoteConfigManager: remoteConfigManagerSpy,
			currentSystemUptime: { 1 * 3600 },
			now: { now }
		)
		
		trackForMemoryLeak(instance: remoteConfigManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return sut
	}
	
	// MARK: - Tests
	
	func test_initialState() {
		
		// Arrange
		let sut = makeSUT()
		
		// Act
		
		// Assert
		expect(sut.hasSignificantDeviation) == nil
	}
	
	func test_updateWithServerDateString_withSignificantDeviation() {
		
		// Arrange
		let sut = makeSUT()
		
		// Act
		sut.update(serverHeaderDate: "Sat, 07 Aug 2021 12:12:57 GMT", ageHeader: nil)
		
		// Assert
		expect(sut.hasSignificantDeviation) == true
	}
	
	func test_updateWithServerDateString_withoutSignificantDeviation() {
		
		// Arrange
		let sut = makeSUT()
		
		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:30 GMT", ageHeader: nil)
		
		// Assert
		expect(sut.hasSignificantDeviation) == false
	}
	
	func test_updateWithServerDateString_withSignificantDeviation_withAgeHeader() {
		
		// Arrange
		let sut = makeSUT()
		
		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:00 GMT", ageHeader: "30")
		
		// Assert
		expect(sut.hasSignificantDeviation) == false
	}
	
	func test_deviationchange_notification() {
		
		// Arrange
		let sut = makeSUT()
		var receivedValue: Bool?
		_ = sut.observatory.append { hasDeviation in
			receivedValue = hasDeviation
		}
		
		// Act
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:30 GMT", ageHeader: nil)
		
		// Assert
		expect(receivedValue) == false
	}
	
	func test_reactsToSystemDateChange() {
		
		// Arrange
		let sut = makeSUT()
		var receivedCount = 0
		_ = sut.observatory.append { hasDeviation in
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
