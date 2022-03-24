/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR

class SecurityCheckerProtocolSpy: SecurityCheckerProtocol {

	var invokedCheckSSL = false
	var invokedCheckSSLCount = 0

	func checkSSL() {
		invokedCheckSSL = true
		invokedCheckSSLCount += 1
	}
}
