/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR

class PDFExportFlowDelegateSpy: PDFExportFlowDelegate {

	var invokedExportCompleted = false
	var invokedExportCompletedCount = 0

	func exportCompleted() {
		invokedExportCompleted = true
		invokedExportCompletedCount += 1
	}

	var invokedExportFailed = false
	var invokedExportFailedCount = 0

	func exportFailed() {
		invokedExportFailed = true
		invokedExportFailedCount += 1
	}
}
