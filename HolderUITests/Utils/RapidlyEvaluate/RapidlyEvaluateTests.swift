/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoreFoundation
import XCTest

class RapidlyEvaluateTests: XCTestCase {
	
	func testPassingImmediately() throws {
		
		let result = rapidlyEvaluate {
			true
		}
		
		XCTAssertTrue(result)
	}
	
	func testPassingEventually() throws {
		
		let until = Date(timeIntervalSinceNow: 1)
		
		let result = rapidlyEvaluate {
			until < Date()
		}
		
		XCTAssertTrue(result)
	}
	
	func testFailingWithTimeout() throws {
		
		let until = Date(timeIntervalSinceNow: 2)
		
		let result = rapidlyEvaluate(timeout: 1) {
			until < Date()
		}
		
		XCTAssertFalse(result)
	}
}
