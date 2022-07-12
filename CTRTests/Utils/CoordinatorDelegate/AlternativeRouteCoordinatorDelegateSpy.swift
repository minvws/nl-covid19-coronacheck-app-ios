/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

class AlternativeRouteCoordinatorDelegateSpy: AlternativeRouteCoordinatorDelegate {

	var invokedUserWishesToCheckForBSN = false
	var invokedUserWishesToCheckForBSNCount = 0

	func userWishesToCheckForBSN() {
		invokedUserWishesToCheckForBSN = true
		invokedUserWishesToCheckForBSNCount += 1
	}

	var invokedUserWishesToCheckForDigiD = false
	var invokedUserWishesToCheckForDigiDCount = 0

	func userWishesToCheckForDigiD() {
		invokedUserWishesToCheckForDigiD = true
		invokedUserWishesToCheckForDigiDCount += 1
	}

	var invokedUserWishesToRequestADigiD = false
	var invokedUserWishesToRequestADigiDCount = 0

	func userWishesToRequestADigiD() {
		invokedUserWishesToRequestADigiD = true
		invokedUserWishesToRequestADigiDCount += 1
	}

	var invokedUserWishesToEndAlternativeRoute = false
	var invokedUserWishesToEndAlternativeRouteCount = 0
	var invokedUserWishesToEndAlternativeRouteParameters: (popViewController: Bool, Void)?
	var invokedUserWishesToEndAlternativeRouteParametersList = [(popViewController: Bool, Void)]()

	func userWishesToEndAlternativeRoute(popViewController: Bool) {
		invokedUserWishesToEndAlternativeRoute = true
		invokedUserWishesToEndAlternativeRouteCount += 1
		invokedUserWishesToEndAlternativeRouteParameters = (popViewController, ())
		invokedUserWishesToEndAlternativeRouteParametersList.append((popViewController, ()))
	}

	var invokedUserWishesToContactHelpDeksWithBSN = false
	var invokedUserWishesToContactHelpDeksWithBSNCount = 0

	func userWishesToContactHelpDeksWithBSN() {
		invokedUserWishesToContactHelpDeksWithBSN = true
		invokedUserWishesToContactHelpDeksWithBSNCount += 1
	}

	var invokedUserHasNoBSN = false
	var invokedUserHasNoBSNCount = 0

	func userHasNoBSN() {
		invokedUserHasNoBSN = true
		invokedUserHasNoBSNCount += 1
	}

	var invokedUserWishedToGoToGGDPortal = false
	var invokedUserWishedToGoToGGDPortalCount = 0

	func userWishedToGoToGGDPortal() {
		invokedUserWishedToGoToGGDPortal = true
		invokedUserWishedToGoToGGDPortalCount += 1
	}

	var invokedUserWishesToContactProviderHelpDeskWhilePortalEnabled = false
	var invokedUserWishesToContactProviderHelpDeskWhilePortalEnabledCount = 0

	func userWishesToContactProviderHelpDeskWhilePortalEnabled() {
		invokedUserWishesToContactProviderHelpDeskWhilePortalEnabled = true
		invokedUserWishesToContactProviderHelpDeskWhilePortalEnabledCount += 1
	}
}
