/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ScanInstructionsDelegateSpy: ScanInstructionsDelegate {

	var invokedScanInstructionsWasCancelled = false
	var invokedScanInstructionsWasCancelledCount = 0

	func scanInstructionsWasCancelled() {
		invokedScanInstructionsWasCancelled = true
		invokedScanInstructionsWasCancelledCount += 1
	}

	var invokedScanInstructionsDidFinish = false
	var invokedScanInstructionsDidFinishCount = 0
	var invokedScanInstructionsDidFinishParameters: (hasScanLock: Bool, Void)?
	var invokedScanInstructionsDidFinishParametersList = [(hasScanLock: Bool, Void)]()

	func scanInstructionsDidFinish(hasScanLock: Bool) {
		invokedScanInstructionsDidFinish = true
		invokedScanInstructionsDidFinishCount += 1
		invokedScanInstructionsDidFinishParameters = (hasScanLock, ())
		invokedScanInstructionsDidFinishParametersList.append((hasScanLock, ()))
	}
}
