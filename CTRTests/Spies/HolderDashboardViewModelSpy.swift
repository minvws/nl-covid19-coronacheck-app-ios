/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	var invokedSelectedTabGetter = false
	var invokedSelectedTabGetterCount = 0
	var stubbedSelectedTab: Observable<DashboardTab>!

	var selectedTab: Observable<DashboardTab> {
		invokedSelectedTabGetter = true
		invokedSelectedTabGetterCount += 1
		return stubbedSelectedTab
	}

	var invokedShouldShowTabBarGetter = false
	var invokedShouldShowTabBarGetterCount = 0
	var stubbedShouldShowTabBar: Observable<Bool>!

	var shouldShowTabBar: Observable<Bool> {
		invokedShouldShowTabBarGetter = true
		invokedShouldShowTabBarGetterCount += 1
		return stubbedShouldShowTabBar
	}

	var invokedShouldShowOnlyInternationalPaneGetter = false
	var invokedShouldShowOnlyInternationalPaneGetterCount = 0
	var stubbedShouldShowOnlyInternationalPane: Observable<Bool>!

	var shouldShowOnlyInternationalPane: Observable<Bool> {
		invokedShouldShowOnlyInternationalPaneGetter = true
		invokedShouldShowOnlyInternationalPaneGetterCount += 1
		return stubbedShouldShowOnlyInternationalPane
	}

	var invokedSelectTab = false
	var invokedSelectTabCount = 0
	var invokedSelectTabParameters: (newTab: DashboardTab, Void)?
	var invokedSelectTabParametersList = [(newTab: DashboardTab, Void)]()

	func selectTab(newTab: DashboardTab) {
		invokedSelectTab = true
		invokedSelectTabCount += 1
		invokedSelectTabParameters = (newTab, ())
		invokedSelectTabParametersList.append((newTab, ()))
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
