/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

class SyncCacheTests: XCTestCase {
	
	func testInsertAndRecall() {
		
		let cache = SyncCache<String, String>()
		cache["hello"] = "goodbye"
		cache["goededag"] = "doie"
		
		expect(cache["hello"]) == "goodbye"
		expect(cache["goededag"]) == "doie"
	}
}
