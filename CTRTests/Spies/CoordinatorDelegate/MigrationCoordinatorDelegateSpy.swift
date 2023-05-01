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

	var invokedUserWishesToSeeToThisDeviceInstructions = false
	var invokedUserWishesToSeeToThisDeviceInstructionsCount = 0

	func userWishesToSeeToThisDeviceInstructions() {
		invokedUserWishesToSeeToThisDeviceInstructions = true
		invokedUserWishesToSeeToThisDeviceInstructionsCount += 1
	}

	var invokedUserWishesToSeeToOtherDeviceInstructions = false
	var invokedUserWishesToSeeToOtherDeviceInstructionsCount = 0

	func userWishesToSeeToOtherDeviceInstructions() {
		invokedUserWishesToSeeToOtherDeviceInstructions = true
		invokedUserWishesToSeeToOtherDeviceInstructionsCount += 1
	}

	var invokedUserWishesToStartMigrationToThisDevice = false
	var invokedUserWishesToStartMigrationToThisDeviceCount = 0

	func userWishesToStartMigrationToThisDevice() {
		invokedUserWishesToStartMigrationToThisDevice = true
		invokedUserWishesToStartMigrationToThisDeviceCount += 1
	}

	var invokedUserWishesToStartMigrationToOtherDevice = false
	var invokedUserWishesToStartMigrationToOtherDeviceCount = 0

	func userWishesToStartMigrationToOtherDevice() {
		invokedUserWishesToStartMigrationToOtherDevice = true
		invokedUserWishesToStartMigrationToOtherDeviceCount += 1
	}

	var invokedUserCompletedMigrationToOtherDevice = false
	var invokedUserCompletedMigrationToOtherDeviceCount = 0

	func userCompletedMigrationToOtherDevice() {
		invokedUserCompletedMigrationToOtherDevice = true
		invokedUserCompletedMigrationToOtherDeviceCount += 1
	}
}
