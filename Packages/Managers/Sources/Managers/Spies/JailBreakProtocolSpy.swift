/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class JailBreakProtocolSpy: JailBreakProtocol {

	var invokedIsJailBroken = false
	var invokedIsJailBrokenCount = 0
	var stubbedIsJailBrokenResult: Bool! = false

	func isJailBroken() -> Bool {
		invokedIsJailBroken = true
		invokedIsJailBrokenCount += 1
		return stubbedIsJailBrokenResult
	}
}
