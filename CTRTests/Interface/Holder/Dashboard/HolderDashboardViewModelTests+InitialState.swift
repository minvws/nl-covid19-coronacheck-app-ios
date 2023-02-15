/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import CoreData
import Shared
@testable import Models
@testable import Resources

extension HolderDashboardViewModelTests {

	// MARK: - Initial State

	func test_initialStateBeforeDatasourceReload_International() {
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion, activeDisclosurePolicies: [.policy1G])
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter.value) == true
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.internationalCards.value).toEventually(haveCount(2))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holderDashboardEmptyInternationalMessage()
			expect(buttonTitle) == L.holderDashboardEmptyInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beEmptyStatePlaceholderImage(test: { image, title in
			expect(title) == L.holderDashboardEmptyInternationalTitle()
			expect(image) == I.dashboard.international()!
		}))
	}
	
	func test_initialStateBeforeDatasourceReload_3G() {
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter.value) == true
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_empty_domestic_only3Gaccess_message()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
			expect(title) == L.holder_dashboard_only3GaccessBanner_title()
			expect(buttonText) == L.general_readmore()
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage(test: { image, title in
			expect(title) == L.holderDashboardEmptyDomesticTitle()
			expect(image) == I.dashboard.domestic()!
		}))
	}
	func test_initialStateBeforeDatasourceReload_1G() {
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter.value) == true
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_empty_domestic_only1Gaccess_message()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
			expect(title) == L.holder_dashboard_only1GaccessBanner_title()
			expect(buttonText) == L.general_readmore()
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage(test: { image, title in
			expect(title) == L.holderDashboardEmptyDomesticTitle()
			expect(image) == I.dashboard.domestic()!
		}))
	}
	
	func test_initialStateBeforeDatasourceReload_1G3G() {
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G, .policy1G])
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter.value) == true
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_empty_domestic_3Gand1Gaccess_message()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, _, _ in
			expect(title) == L.holder_dashboard_3Gand1GaccessBanner_title()
			expect(buttonText) == L.general_readmore()
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage(test: { image, title in
			expect(title) == L.holderDashboardEmptyDomesticTitle()
			expect(image) == I.dashboard.domestic()!
		}))
	}
	
	func test_initialStateAfterEmptyDatasourceLoad() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], [])

		// Assert
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.shouldShowAddCertificateFooter.value).toEventually(beTrue())
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value).toEventually(haveCount(2))

		expect(self.sut.domesticCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).to(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).to(beEmptyStatePlaceholderImage())
	}
}
