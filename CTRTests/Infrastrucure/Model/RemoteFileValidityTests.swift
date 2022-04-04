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

class RemoteFileValidityTests: XCTestCase {
	
	func test_lastFetchedTimestamp_nil() {
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: .default,
			lastFetchedTimestamp: nil,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .neverFetched
	}
	
	func test_lastFetchedTimestamp_inFuture() {
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: .default,
			lastFetchedTimestamp: now.addingTimeInterval(10 * days * fromNow).timeIntervalSince1970,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .refreshNeeded
	}
	
	func test_lastFetchedTimestamp_greaterthan_ttlThreshold_withNilConfigMinimumIntervalSeconds() {
		
		var config: RemoteConfiguration = .default
		config.configMinimumIntervalSeconds = nil
		config.configTTL = Int(5 * days)
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: config,
			lastFetchedTimestamp: now.addingTimeInterval(1 * day * ago).timeIntervalSince1970,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .withinTTL
	}
	
	func test_lastFetchedTimestamp_lessthan_ttlThreshold_withNilConfigMinimumIntervalSeconds() {
		
		var config: RemoteConfiguration = .default
		config.configMinimumIntervalSeconds = nil
		config.configTTL = Int(5 * days)
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: config,
			lastFetchedTimestamp: now.addingTimeInterval(10 * days * ago).timeIntervalSince1970,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .refreshNeeded
	}

	func test_lastFetchedTimestamp_greaterthan_ttlThreshold_notWithinMinimumTimeInterval() {
		
		var config: RemoteConfiguration = .default
		config.configMinimumIntervalSeconds = Int(1 * hour)
		config.configTTL = Int(5 * days)
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: config,
			lastFetchedTimestamp: now.addingTimeInterval(1 * day * ago).timeIntervalSince1970,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .withinTTL
	}
	
	func test_lastFetchedTimestamp_lessthan_ttlThreshold_notWithinMinimumTimeInterval() {
		
		var config: RemoteConfiguration = .default
		config.configMinimumIntervalSeconds = Int(1 * hour)
		config.configTTL = Int(5 * days)
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: config,
			lastFetchedTimestamp: now.addingTimeInterval(10 * day * ago).timeIntervalSince1970,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .refreshNeeded
	}
	
	func test_lastFetchedTimestamp_greaterthan_ttlThreshold_withinMinimumTimeInterval_appNotLaunching() {
		
		var config: RemoteConfiguration = .default
		config.configMinimumIntervalSeconds = Int(1 * hour)
		config.configTTL = Int(5 * days)
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: config,
			lastFetchedTimestamp: now.addingTimeInterval(5 * minutes * ago).timeIntervalSince1970,
			isAppLaunching: false,
			now: { now }
		)
		
		expect(result) == .withinMinimalInterval
	}
	
	func test_lastFetchedTimestamp_greaterthan_ttlThreshold_withinMinimumTimeInterval_appLaunching() {
		
		var config: RemoteConfiguration = .default
		config.configMinimumIntervalSeconds = Int(1 * hour)
		config.configTTL = Int(5 * days)
		
		let result = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: config,
			lastFetchedTimestamp: now.addingTimeInterval(5 * minutes * ago).timeIntervalSince1970,
			isAppLaunching: true,
			now: { now }
		)
		
		expect(result) == .withinTTL
	}
}
