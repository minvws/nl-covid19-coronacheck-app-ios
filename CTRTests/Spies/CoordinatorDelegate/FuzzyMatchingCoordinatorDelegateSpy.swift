/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import ReusableViews

final class FuzzyMatchingCoordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegate {

	var invokedUserHasSelectedIdentityGroup = false
	var invokedUserHasSelectedIdentityGroupCount = 0
	var invokedUserHasSelectedIdentityGroupParameters: (selectedBlobIds: [String], Void)?
	var invokedUserHasSelectedIdentityGroupParametersList = [(selectedBlobIds: [String], Void)]()

	func userHasSelectedIdentityGroup(selectedBlobIds: [String]) {
		invokedUserHasSelectedIdentityGroup = true
		invokedUserHasSelectedIdentityGroupCount += 1
		invokedUserHasSelectedIdentityGroupParameters = (selectedBlobIds, ())
		invokedUserHasSelectedIdentityGroupParametersList.append((selectedBlobIds, ()))
	}

	var invokedUserHasFinishedTheFlow = false
	var invokedUserHasFinishedTheFlowCount = 0

	func userHasFinishedTheFlow() {
		invokedUserHasFinishedTheFlow = true
		invokedUserHasFinishedTheFlowCount += 1
	}

	var invokedUserHasStoppedTheFlow = false
	var invokedUserHasStoppedTheFlowCount = 0

	func userHasStoppedTheFlow() {
		invokedUserHasStoppedTheFlow = true
		invokedUserHasStoppedTheFlowCount += 1
	}

	var invokedUserWishesMoreInfoAboutWhy = false
	var invokedUserWishesMoreInfoAboutWhyCount = 0

	func userWishesMoreInfoAboutWhy() {
		invokedUserWishesMoreInfoAboutWhy = true
		invokedUserWishesMoreInfoAboutWhyCount += 1
	}

	var invokedUserWishesToSeeIdentityGroups = false
	var invokedUserWishesToSeeIdentityGroupsCount = 0

	func userWishesToSeeIdentityGroups() {
		invokedUserWishesToSeeIdentityGroups = true
		invokedUserWishesToSeeIdentityGroupsCount += 1
	}

	var invokedUserWishesToSeeIdentitySelectionDetails = false
	var invokedUserWishesToSeeIdentitySelectionDetailsCount = 0
	var invokedUserWishesToSeeIdentitySelectionDetailsParameters: (identitySelectionDetails: IdentitySelectionDetails, Void)?
	var invokedUserWishesToSeeIdentitySelectionDetailsParametersList = [(identitySelectionDetails: IdentitySelectionDetails, Void)]()

	func userWishesToSeeIdentitySelectionDetails(_ identitySelectionDetails: IdentitySelectionDetails) {
		invokedUserWishesToSeeIdentitySelectionDetails = true
		invokedUserWishesToSeeIdentitySelectionDetailsCount += 1
		invokedUserWishesToSeeIdentitySelectionDetailsParameters = (identitySelectionDetails, ())
		invokedUserWishesToSeeIdentitySelectionDetailsParametersList.append((identitySelectionDetails, ()))
	}

	var invokedUserWishesToSeeSuccess = false
	var invokedUserWishesToSeeSuccessCount = 0
	var invokedUserWishesToSeeSuccessParameters: (name: String, Void)?
	var invokedUserWishesToSeeSuccessParametersList = [(name: String, Void)]()

	func userWishesToSeeSuccess(name: String) {
		invokedUserWishesToSeeSuccess = true
		invokedUserWishesToSeeSuccessCount += 1
		invokedUserWishesToSeeSuccessParameters = (name, ())
		invokedUserWishesToSeeSuccessParametersList.append((name, ()))
	}

	var invokedPresentError = false
	var invokedPresentErrorCount = 0
	var invokedPresentErrorParameters: (content: Content, Void)?
	var invokedPresentErrorParametersList = [(content: Content, Void)]()
	var shouldInvokePresentErrorBackAction = false

	func presentError(content: Content, backAction: (() -> Void)?) {
		invokedPresentError = true
		invokedPresentErrorCount += 1
		invokedPresentErrorParameters = (content, ())
		invokedPresentErrorParametersList.append((content, ()))
		if shouldInvokePresentErrorBackAction {
			backAction?()
		}
	}

	var invokedRestartFlow = false
	var invokedRestartFlowCount = 0
	var invokedRestartFlowParameters: (matchingBlobIds: [[String]], Void)?
	var invokedRestartFlowParametersList = [(matchingBlobIds: [[String]], Void)]()

	func restartFlow(matchingBlobIds: [[String]]) {
		invokedRestartFlow = true
		invokedRestartFlowCount += 1
		invokedRestartFlowParameters = (matchingBlobIds, ())
		invokedRestartFlowParametersList.append((matchingBlobIds, ()))
	}
}
