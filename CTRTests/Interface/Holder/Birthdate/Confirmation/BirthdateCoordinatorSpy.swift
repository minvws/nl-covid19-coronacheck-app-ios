/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class BirthdateCoordinatorDelegateSpy: BirthdateCoordinatorDelegate & Dismissable {

	var navigateToBirthdayEntryCalled = false
	var navigateToBirthdayConfirmationCalled = false
	var navigateBackToBirthdayEntryCalled = false
	var birthdateConfirmedCalled = false
	var dismissCalled = false

	func navigateToBirthdayEntry() {

		navigateToBirthdayEntryCalled = true
	}

	func navigateToBirthdayConfirmation(_ date: Date) {

		navigateToBirthdayConfirmationCalled = true
	}

	func navigateBackToBirthdayEntry() {

		navigateBackToBirthdayEntryCalled = true
	}

	func birthdateConfirmed() {

		birthdateConfirmedCalled = true
	}

	func dismiss() {

		dismissCalled = true
	}
}
