/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class EventFlowDelegateSpy: EventFlowDelegate {

	var invokedEventFlowDidComplete = false
	var invokedEventFlowDidCompleteCount = 0

	func eventFlowDidComplete() {
		invokedEventFlowDidComplete = true
		invokedEventFlowDidCompleteCount += 1
	}

	var invokedEventFlowDidCancel = false
	var invokedEventFlowDidCancelCount = 0

	func eventFlowDidCancel() {
		invokedEventFlowDidCancel = true
		invokedEventFlowDidCancelCount += 1
	}

	var invokedEventFlowDidCancelFromBackSwipe = false
	var invokedEventFlowDidCancelFromBackSwipeCount = 0

	func eventFlowDidCancelFromBackSwipe() {
		invokedEventFlowDidCancelFromBackSwipe = true
		invokedEventFlowDidCancelFromBackSwipeCount += 1
	}
}
