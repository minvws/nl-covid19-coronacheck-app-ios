/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class JailBreakProtocolSpy: JailBreakProtocol {

	var invokedIsJailBroken = false
	var invokedIsJailBrokenCount = 0
	var stubbedIsJailBrokenResult: Bool! = false

	func isJailBroken() -> Bool {
		invokedIsJailBroken = true
		invokedIsJailBrokenCount += 1
		return stubbedIsJailBrokenResult
	}

	var invokedShouldWarnUser = false
	var invokedShouldWarnUserCount = 0
	var stubbedShouldWarnUserResult: Bool! = false

	func shouldWarnUser() -> Bool {
		invokedShouldWarnUser = true
		invokedShouldWarnUserCount += 1
		return stubbedShouldWarnUserResult
	}

	var invokedWarningHasBeenSeen = false
	var invokedWarningHasBeenSeenCount = 0

	func warningHasBeenSeen() {
		invokedWarningHasBeenSeen = true
		invokedWarningHasBeenSeenCount += 1
	}
}
