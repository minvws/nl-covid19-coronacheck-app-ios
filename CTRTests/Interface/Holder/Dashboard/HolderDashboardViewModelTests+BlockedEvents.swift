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

extension HolderDashboardViewModelTests {
	
	// MARK: Blocked Events
	
	func test_blockedEvent_zeroInDB_doesntShowBanner() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		blockedEventsSpy.invokedDidUpdate?([])
		
		// Assert
		expect {
			self.sut.internationalCards.value.first { (card: HolderDashboardViewController.Card) in
				if case .eventsWereRemoved = card { return true }
				return false
			}
		}.toEventually(beNil())
	}
	
	func test_blockedEvent_eventBeingAdded_hasNotSeenAlert_triggersBannerAndShowsAlert() throws {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 0
		blockedEventsSpy.invokedDidUpdate?([RemovedEventItem(objectID: NSManagedObjectID(), eventDate: now, reason: "the reason", type: .vaccination)])
		
		// Assert
		
		// Check alert:
		
		let alert = try XCTUnwrap(eventuallyUnwrap { self.sut.currentlyPresentedAlert.value })
		alert.alertWasPresentedCallback?()
		
		expect(alert.title) == L.holder_invaliddetailsremoved_alert_title()
		expect(alert.subTitle) == L.holder_invaliddetailsremoved_alert_body()
		expect(alert.okAction.title) == L.holder_invaliddetailsremoved_alert_button_moreinfo()
		
		alert.okAction.action?(UIAlertAction()) // trigger the okay button
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount) == 1
		
		expect(alert.cancelAction?.title) == L.holder_invaliddetailsremoved_alert_button_close()
		
		// Check banner:

		let eventsWereBlockedBannerValues = try XCTUnwrap(eventuallyUnwrap {
			let matchingTuples = self.sut.internationalCards.value.compactMap { card -> (String, String, () -> Void, () -> Void)? in
				if case let .eventsWereRemoved(message, callToActionButtonText, didTapCallToAction, didTapDismiss) = card {
					return (message, callToActionButtonText, didTapCallToAction, didTapDismiss)
				}
				return nil
			}
			return matchingTuples.first
		})

		let (message, callToActionButtonText, didTapCallToAction, didTapDismiss) = eventsWereBlockedBannerValues
		expect(message) == L.holder_invaliddetailsremoved_banner_title()
		expect(callToActionButtonText) == L.holder_invaliddetailsremoved_banner_button_readmore()
		
		// Check the CTA button handler:
		didTapCallToAction()
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount) == 2
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 1
		
		// Check the cancel button handler
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingBlockedEvents) == false
		didTapDismiss()
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingBlockedEvents).toEventually(beTrue())
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount) == 2 // still same as above
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 2
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlert) == false
	}
	
	func test_blockedEvent_eventBeingAdded_hasAlreadySeenAlert_triggersBannerAndDoesNotAlert() throws {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedHasShownBlockedEventsAlert = true
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		blockedEventsSpy.invokedDidUpdate?([RemovedEventItem(objectID: NSManagedObjectID(), eventDate: now, reason: "the reason", type: .vaccination)])
		
		// Assert
		let eventsWereBlockedValues = try XCTUnwrap(eventuallyUnwrap {
			let matchingTuples = self.sut.internationalCards.value.compactMap { card -> (String, String, () -> Void, () -> Void)? in
				if case let .eventsWereRemoved(message, callToActionButtonText, didTapCallToAction, didTapDismiss) = card {
					return (message, callToActionButtonText, didTapCallToAction, didTapDismiss)
				}
				return nil
			}
			return matchingTuples.first
		})

		let (message, callToActionButtonText, _, _) = eventsWereBlockedValues
		expect(message) == L.holder_invaliddetailsremoved_banner_title()
		expect(callToActionButtonText) == L.holder_invaliddetailsremoved_banner_button_readmore()
		
		expect(self.sut.currentlyPresentedAlert.value).toEventually(beNil())
	}
	
	// MARK: Mismatched Identity Events
	
	func test_mismatchedIdentityEvent_zeroInDB_doesntShowBanner() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		mismatchedIdentityEventsSpy.invokedDidUpdate?([])
		
		// Assert
		expect {
			self.sut.internationalCards.value.first { (card: HolderDashboardViewController.Card) in
				if case .eventsWereRemoved = card { return true }
				return false
			}
		}.toEventually(beNil())
	}
	
	func test_mismatchedIdentityEvent_eventBeingAdded_triggersBanner() throws {
		// Arrange
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "de Tester, Test"
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		mismatchedIdentityEventsSpy.invokedDidUpdate?([RemovedEventItem(objectID: NSManagedObjectID(), eventDate: now, reason: "the reason", type: .vaccination)])
		
		// Assert

		let eventsWereRemovedBannerValues = try XCTUnwrap(eventuallyUnwrap {
			let matchingTuples = self.sut.internationalCards.value.compactMap { card -> (String, String, () -> Void, () -> Void)? in
				if case let .eventsWereRemoved(message, callToActionButtonText, didTapCallToAction, didTapDismiss) = card {
					return (message, callToActionButtonText, didTapCallToAction, didTapDismiss)
				}
				return nil
			}
			return matchingTuples.first
		})

		let (message, callToActionButtonText, didTapCallToAction, didTapDismiss) = eventsWereRemovedBannerValues
		expect(message) == L.holder_identityRemoved_banner_title()
		expect(callToActionButtonText) == L.holder_identityRemoved_banner_button_readmore()
		
		// Check the CTA button handler:
		didTapCallToAction()
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted) == true

		// Check the cancel button handler
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingMismatchedIdentityEvents) == false
		expect(self.environmentSpies.secureUserSettingsSpy.selectedIdentity) == "de Tester, Test"

		didTapDismiss()
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingBlockedEvents) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingMismatchedIdentityEvents).toEventually(beTrue())
		expect(self.environmentSpies.secureUserSettingsSpy.invokedSelectedIdentitySetter) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedSelectedIdentity) == nil

	}
}
