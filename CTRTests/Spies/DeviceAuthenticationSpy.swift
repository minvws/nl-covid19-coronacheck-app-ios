/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import XCTest
@testable import CTR

class DeviceAuthenticationSpy: DeviceAuthenticationProtocol {

	required init() {}

	var invokedHasAuthenticationPolicy = false
	var invokedHasAuthenticationPolicyCount = 0
	var stubbedHasAuthenticationPolicyResult: Bool! = false

	func hasAuthenticationPolicy() -> Bool {
		invokedHasAuthenticationPolicy = true
		invokedHasAuthenticationPolicyCount += 1
		return stubbedHasAuthenticationPolicyResult
	}
}
