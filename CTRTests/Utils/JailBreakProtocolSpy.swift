/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class JailBreakProtocolSpy: JailBreakProtocol {

	required init() {}

	var invokedIsJailBroken = false
	var invokedIsJailBrokenCount = 0
	var stubbedIsJailBrokenResult: Bool! = false

	func isJailBroken() -> Bool {
		invokedIsJailBroken = true
		invokedIsJailBrokenCount += 1
		return stubbedIsJailBrokenResult
	}
}
