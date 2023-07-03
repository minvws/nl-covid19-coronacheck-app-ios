/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
@testable import CTR
import ReusableViews
@testable import Models

class HolderDashboardViewModelSpy: HolderDashboardViewModelType {

	var invokedTitleGetter = false
	var invokedTitleGetterCount = 0
	var stubbedTitle: Observable<String>!

	var title: Observable<String> {
		invokedTitleGetter = true
		invokedTitleGetterCount += 1
		return stubbedTitle
	}

	var invokedInternationalCardsGetter = false
	var invokedInternationalCardsGetterCount = 0
	var stubbedInternationalCards: Observable<[HolderDashboardViewController.Card]>!

	var internationalCards: Observable<[HolderDashboardViewController.Card]> {
		invokedInternationalCardsGetter = true
		invokedInternationalCardsGetterCount += 1
		return stubbedInternationalCards
	}

	var invokedPrimaryButtonTitleGetter = false
	var invokedPrimaryButtonTitleGetterCount = 0
	var stubbedPrimaryButtonTitle: Observable<String>!

	var primaryButtonTitle: Observable<String> {
		invokedPrimaryButtonTitleGetter = true
		invokedPrimaryButtonTitleGetterCount += 1
		return stubbedPrimaryButtonTitle
	}

	var invokedShouldShowAddCertificateFooterGetter = false
	var invokedShouldShowAddCertificateFooterGetterCount = 0
	var stubbedShouldShowAddCertificateFooter: Observable<Bool>!

	var shouldShowAddCertificateFooter: Observable<Bool> {
		invokedShouldShowAddCertificateFooterGetter = true
		invokedShouldShowAddCertificateFooterGetterCount += 1
		return stubbedShouldShowAddCertificateFooter
	}

	var invokedCurrentlyPresentedAlertGetter = false
	var invokedCurrentlyPresentedAlertGetterCount = 0
	var stubbedCurrentlyPresentedAlert: Observable<AlertContent?>!

	var currentlyPresentedAlert: Observable<AlertContent?> {
		invokedCurrentlyPresentedAlertGetter = true
		invokedCurrentlyPresentedAlertGetterCount += 1
		return stubbedCurrentlyPresentedAlert
	}

	var invokedViewWillAppear = false
	var invokedViewWillAppearCount = 0

	func viewWillAppear() {
		invokedViewWillAppear = true
		invokedViewWillAppearCount += 1
	}

	var invokedAddCertificateFooterTapped = false
	var invokedAddCertificateFooterTappedCount = 0

	func addCertificateFooterTapped() {
		invokedAddCertificateFooterTapped = true
		invokedAddCertificateFooterTappedCount += 1
	}

	var invokedUserTappedMenuButton = false
	var invokedUserTappedMenuButtonCount = 0

	func userTappedMenuButton() {
		invokedUserTappedMenuButton = true
		invokedUserTappedMenuButtonCount += 1
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()

	func openUrl(_ url: URL) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
	}
}
