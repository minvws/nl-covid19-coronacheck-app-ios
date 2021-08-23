/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class ScanInstructionsCoordinatorDelegateSpy: ScanInstructionsCoordinatorDelegate {

	var invokedUserDidCompletePages = false
	var invokedUserDidCompletePagesCount = 0

	func userDidCompletePages() {
		invokedUserDidCompletePages = true
		invokedUserDidCompletePagesCount += 1
	}

	var invokedUserDidCancelScanInstructions = false
	var invokedUserDidCancelScanInstructionsCount = 0

	func userDidCancelScanInstructions() {
		invokedUserDidCancelScanInstructions = true
		invokedUserDidCancelScanInstructionsCount += 1
	}
}
