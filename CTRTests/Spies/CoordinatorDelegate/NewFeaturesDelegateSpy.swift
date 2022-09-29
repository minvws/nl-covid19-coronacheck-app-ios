/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class NewFeaturesDelegateSpy: NewFeaturesDelegate {

	var invokedFinishNewFeatures = false
	var invokedFinishNewFeaturesCount = 0

	func finishNewFeatures() {
		invokedFinishNewFeatures = true
		invokedFinishNewFeaturesCount += 1
	}
}
