/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI
import XCTest
@testable import CTR
import Nimble
import CoreData

extension HolderDashboardViewModelTests {

	// MARK: - Initial State

	func test_initialStateBeforeDatasourceReload_International() {
		environmentSpies.featureFlagManagerSpy.stubbedIsAddingEventsEnabledResult = true
		sut = vendSut()
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter.value) == true
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_emptyState_international_0G_message()
			expect(buttonTitle) == L.holder_dashboard_international_0G_action_certificateNeeded()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage(test: { image, title in
			expect(title) == L.holderDashboardEmptyInternationalTitle()
			expect(image) == I.dashboard.international()!
		}))
	}
	
	func test_initialStateBeforeDatasourceReload_International_addEventsDisabled() {
		environmentSpies.featureFlagManagerSpy.stubbedIsAddingEventsEnabledResult = false
		sut = vendSut()
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.shouldShowAddCertificateFooter.value) == false
		expect(self.sut.currentlyPresentedAlert.value) == nil
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_emptyState_international_0G_message()
			expect(buttonTitle) == L.holder_dashboard_international_0G_action_certificateNeeded()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEmptyStatePlaceholderImage(test: { image, title in
			expect(title) == L.holderDashboardEmptyInternationalTitle()
			expect(image) == I.dashboard.international()!
		}))
	}
	
	func test_initialStateAfterEmptyDatasourceLoad() {
		// Arrange
		sut = vendSut()

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], [])

		// Assert
		expect(self.sut.title.value) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle.value) == L.holderMenuProof()
		expect(self.sut.currentlyPresentedAlert.value) == nil

		expect(self.sut.shouldShowAddCertificateFooter.value).toEventually(beTrue())
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))

		expect(self.sut.internationalCards.value[0]).to(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).to(beEmptyStatePlaceholderImage())
	}
}
