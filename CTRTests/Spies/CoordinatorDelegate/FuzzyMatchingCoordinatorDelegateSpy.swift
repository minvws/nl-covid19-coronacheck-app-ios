/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

final class FuzzyMatchingCoordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegate {

	var invokedUserWishesToSeeEventDetails = false
	var invokedUserWishesToSeeEventDetailsCount = 0

	func userWishesToSeeEventDetails() {
		invokedUserWishesToSeeEventDetails = true
		invokedUserWishesToSeeEventDetailsCount += 1
	}

	var invokedUserWishesToSeeIdentitiyGroups = false
	var invokedUserWishesToSeeIdentitiyGroupsCount = 0

	func userWishesToSeeIdentitiyGroups() {
		invokedUserWishesToSeeIdentitiyGroups = true
		invokedUserWishesToSeeIdentitiyGroupsCount += 1
	}

	var invokedUserWishesMoreInfoAboutWhy = false
	var invokedUserWishesMoreInfoAboutWhyCount = 0

	func userWishesMoreInfoAboutWhy() {
		invokedUserWishesMoreInfoAboutWhy = true
		invokedUserWishesMoreInfoAboutWhyCount += 1
	}

	var invokedUserHasFinishedTheFlow = false
	var invokedUserHasFinishedTheFlowCount = 0

	func userHasFinishedTheFlow() {
		invokedUserHasFinishedTheFlow = true
		invokedUserHasFinishedTheFlowCount += 1
	}
}
