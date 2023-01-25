/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
import Shared

class ThreadSafeCacheTests: XCTestCase {
	
	func testInsertAndRecall() {
		
		let cache = ThreadSafeCache<String, String>()
		cache["hello"] = "goodbye"
		cache["goededag"] = "doei"
		
		expect(cache["hello"]) == "goodbye"
		expect(cache["goededag"]) == "doei"
	}
}
