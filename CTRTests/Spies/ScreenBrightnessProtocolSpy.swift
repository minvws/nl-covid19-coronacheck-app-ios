/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation

class ScreenBrightnessProtocolSpy: ScreenBrightnessProtocol {

	var invokedAnimateToFullBrightness = false
	var invokedAnimateToFullBrightnessCount = 0

	func animateToFullBrightness() {
		invokedAnimateToFullBrightness = true
		invokedAnimateToFullBrightnessCount += 1
	}

	var invokedAnimateToInitialBrightness = false
	var invokedAnimateToInitialBrightnessCount = 0

	func animateToInitialBrightness() {
		invokedAnimateToInitialBrightness = true
		invokedAnimateToInitialBrightnessCount += 1
	}
}
