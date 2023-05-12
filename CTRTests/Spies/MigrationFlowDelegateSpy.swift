/*
 * Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import DataMigration

class MigrationFlowDelegateSpy: MigrationFlowDelegate {

	var invokedDataMigrationBackAction = false
	var invokedDataMigrationBackActionCount = 0

	func dataMigrationBackAction() {
		invokedDataMigrationBackAction = true
		invokedDataMigrationBackActionCount += 1
	}

	var invokedDataMigrationCancelled = false
	var invokedDataMigrationCancelledCount = 0

	func dataMigrationCancelled() {
		invokedDataMigrationCancelled = true
		invokedDataMigrationCancelledCount += 1
	}

	var invokedDataMigrationExportCompleted = false
	var invokedDataMigrationExportCompletedCount = 0

	func dataMigrationExportCompleted() {
		invokedDataMigrationExportCompleted = true
		invokedDataMigrationExportCompletedCount += 1
	}

	var invokedDataMigrationImportCompleted = false
	var invokedDataMigrationImportCompletedCount = 0

	func dataMigrationImportCompleted() {
		invokedDataMigrationImportCompleted = true
		invokedDataMigrationImportCompletedCount += 1
	}
}
