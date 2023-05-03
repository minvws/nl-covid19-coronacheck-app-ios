/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Transport

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

	var invokedPresentError = false
	var invokedPresentErrorCount = 0
	var invokedPresentErrorParameters: (errorCode: ErrorCode, Void)?
	var invokedPresentErrorParametersList = [(errorCode: ErrorCode, Void)]()

	func presentError(_ errorCode: ErrorCode) {
		invokedPresentError = true
		invokedPresentErrorCount += 1
		invokedPresentErrorParameters = (errorCode, ())
		invokedPresentErrorParametersList.append((errorCode, ()))
	}

	var invokedUserWishesToSeeScannedEvents = false
	var invokedUserWishesToSeeScannedEventsCount = 0
	var invokedUserWishesToSeeScannedEventsParameters: (parcels: [EventGroupParcel], Void)?
	var invokedUserWishesToSeeScannedEventsParametersList = [(parcels: [EventGroupParcel], Void)]()

	func userWishesToSeeScannedEvents(_ parcels: [EventGroupParcel]) {
		invokedUserWishesToSeeScannedEvents = true
		invokedUserWishesToSeeScannedEventsCount += 1
		invokedUserWishesToSeeScannedEventsParameters = (parcels, ())
		invokedUserWishesToSeeScannedEventsParametersList.append((parcels, ()))
	}
}
