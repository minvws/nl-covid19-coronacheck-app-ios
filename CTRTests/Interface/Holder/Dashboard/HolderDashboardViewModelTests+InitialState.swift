/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import CoreData

extension HolderDashboardViewModelTests {

	// MARK: - Initial State

	func test_initialState() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.sut.title) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter) == true
		expect(self.sut.currentlyPresentedAlert).to(beNil())

		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards[2]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}

	func test_initialStateAfterFirstEmptyLoad() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		datasourceSpy.invokedDidUpdate?([], [])

		// Assert
		expect(self.sut.title) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle) == L.holderMenuProof()
		expect(self.sut.currentlyPresentedAlert).to(beNil())

		expect(self.sut.shouldShowAddCertificateFooter).toEventually(beTrue())
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards).toEventually(haveCount(2))

		expect(self.sut.domesticCards[0]).to(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_empty_domestic_only3Gaccess_message()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, didTapCallToAction, didTapClose in
			expect(title) == title
			expect(buttonText) == buttonText
			
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
			didTapCallToAction()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_dashboard_only3GaccessBanner_link()
			expect(self.holderCoordinatorDelegateSpy.invokedOpenUrlParameters?.inApp) == true
		}))
		expect(self.sut.domesticCards[2]).to(beEmptyStatePlaceholderImage(test: { image, title in
			expect(image) == I.dashboard.domestic()
			expect(title) == L.holderDashboardEmptyDomesticTitle()
		}))

		expect(self.sut.internationalCards[0]).to(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holderDashboardEmptyInternationalMessage()
			expect(buttonTitle) == L.holderDashboardEmptyInternationalButton()
		}))
		expect(self.sut.internationalCards[1]).to(beEmptyStatePlaceholderImage(test: { image, title in
			expect(image) == I.dashboard.international()
			expect(title) == L.holderDashboardEmptyInternationalTitle()
		}))
	}
}
