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
				if case .eventsWereBlocked = card { return true }
				return false
			}
		}.toEventually(beNil())
	}
	
	func test_blockedEvent_eventBeingAdded_hasNotSeenAlert_triggersBannerAndShowsAlert() throws {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		blockedEventsSpy.invokedDidUpdate?([BlockedEventItem(objectID: NSManagedObjectID(), eventDate: now, reason: "the reason", type: .vaccination)])
		
		// Assert
		let eventsWereBlockedValues = try XCTUnwrap(eventuallyUnwrap {
			let matchingTuples = self.sut.internationalCards.value.compactMap { card -> (String, String, () -> Void)? in
				if case let .eventsWereBlocked(message, callToActionButtonText, didTapCallToAction) = card {
					return (message, callToActionButtonText, didTapCallToAction)
				}
				return nil
			}
			return matchingTuples.first
		})

		let (message, callToActionButtonText, didTapCallToAction) = eventsWereBlockedValues
		expect(message) == L.holder_invaliddetailsremoved_banner_title()
		expect(callToActionButtonText) == L.holder_invaliddetailsremoved_banner_button_readmore()
		
		didTapCallToAction()
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount) == 1
		
		let alert = try XCTUnwrap(eventuallyUnwrap { self.sut.currentlyPresentedAlert.value })
		expect(alert.title) == L.holder_invaliddetailsremoved_alert_title()
		expect(alert.subTitle) == L.holder_invaliddetailsremoved_alert_body()
		expect(alert.okAction.title) == L.holder_invaliddetailsremoved_alert_button_moreinfo()
		
		alert.okAction.action?(UIAlertAction()) // trigger the okay button
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount) == 2
		
		expect(alert.cancelAction?.title) == L.holder_invaliddetailsremoved_alert_button_close()
	}
	
	func test_blockedEvent_eventBeingAdded_hasAlreadySeenAlert_triggersBannerAndDoesNotAlert() throws {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedHasShownBlockedEventsAlert = true
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [])
		
		// Act
		blockedEventsSpy.invokedDidUpdate?([BlockedEventItem(objectID: NSManagedObjectID(), eventDate: now, reason: "the reason", type: .vaccination)])
		
		// Assert
		let eventsWereBlockedValues = try XCTUnwrap(eventuallyUnwrap {
			let matchingTuples = self.sut.internationalCards.value.compactMap { card -> (String, String, () -> Void)? in
				if case let .eventsWereBlocked(message, callToActionButtonText, didTapCallToAction) = card {
					return (message, callToActionButtonText, didTapCallToAction)
				}
				return nil
			}
			return matchingTuples.first
		})

		let (message, callToActionButtonText, _) = eventsWereBlockedValues
		expect(message) == L.holder_invaliddetailsremoved_banner_title()
		expect(callToActionButtonText) == L.holder_invaliddetailsremoved_banner_button_readmore()
		
		expect(self.sut.currentlyPresentedAlert.value).toEventually(beNil())
	}
	
}