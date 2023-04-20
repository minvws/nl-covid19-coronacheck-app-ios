/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR

class MigrationCoordinatorDelegateSpy: MigrationCoordinatorDelegate {

	var invokedUserCompletedStart = false
	var invokedUserCompletedStartCount = 0

	func userCompletedStart() {
		invokedUserCompletedStart = true
		invokedUserCompletedStartCount += 1
	}

	var invokedUserWishesToSeeImportInstructions = false
	var invokedUserWishesToSeeImportInstructionsCount = 0

	func userWishesToSeeToThisDeviceInstructions() {
		invokedUserWishesToSeeImportInstructions = true
		invokedUserWishesToSeeImportInstructionsCount += 1
	}

	var invokedUserWishesToSeeExportInstructions = false
	var invokedUserWishesToSeeExportInstructionsCount = 0

	func userWishesToSeeToOtherDeviceInstructions() {
		invokedUserWishesToSeeExportInstructions = true
		invokedUserWishesToSeeExportInstructionsCount += 1
	}
}
