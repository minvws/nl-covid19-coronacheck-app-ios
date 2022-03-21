/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CTR

class TimerSpy: Timeable {

	var invokedInvalidate = false
	var invokedInvalidateCount = 0

	func invalidate() {
		invokedInvalidate = true
		invokedInvalidateCount += 1
	}
}
