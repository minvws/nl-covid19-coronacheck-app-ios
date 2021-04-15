/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ForcedInformationDelegateSpy: ForcedInformationDelegate {

	var invokedFinishForcedInformation = false
	var invokedFinishForcedInformationCount = 0

	func finishForcedInformation() {
		invokedFinishForcedInformation = true
		invokedFinishForcedInformationCount += 1
	}
}
