/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import XCTest
@testable import Transport
@testable import Shared
@testable import CTR
import Nimble
import TestingShared
import Persistence

class UniversalLinkTests: XCTestCase {
	
	func test_validHolderURL_withValidFragment_inHolderApp_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-STXT2VF3389TJ2-Z2")
		
		let expected = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validHolderURL_withValidFragment_inHolderApp_withLunhCheckDisabled_doesNotPassLunhCheck_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		
		let expected = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "YYYYYYYYYYYY",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: false)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validHolderURL_withValidFragment_inHolderApp_withLunhCheckEnsabled_doesNotPassLunhCheck_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validHolderURL_inVerifierApp_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		
		let link = UniversalLink(userActivity: activity, appFlavor: .verifier, isLunhCheckEnabled: true)
		
		XCTAssertNil(link)
	}
	
	func test_validHolderURL_withInvalidFragment1_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z_") // invalid token in URL fragment
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validHolderURL_withInvalidFragment2_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#Xsdfsdf") // invalid token in URL fragment
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_rejectsUserActivity_ifNotOfType_NSUserActivityTypeBrowsingWeb() {
		
		// Arrange
		let activity = NSUserActivity(activityType: "Other")
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validHAssessmentURL_withValidFragment_inHolderApp_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem/assessment#XXX-STXT2VF3389TJ2-Z2")
		
		let expected = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validAssessmentURL_withValidFragment_inHolderApp_withLunhCheckDisabled_doesNotPassLunhCheck_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem/assessment#XXX-YYYYYYYYYYYY-Z2")
		
		let expected = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "YYYYYYYYYYYY",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: false)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validAssessmentURL_withValidFragment_inHolderApp_withLunhCheckEnsabled_doesNotPassLunhCheck_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem/assessment#XXX-YYYYYYYYYYYY-Z2")
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validAssessmentURL_inVerifierApp_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem/assessment#XXX-YYYYYYYYYYYY-Z2")
		
		let link = UniversalLink(userActivity: activity, appFlavor: .verifier, isLunhCheckEnabled: true)
		
		XCTAssertNil(link)
	}
	
	func test_validAssessmentURL_withInvalidFragment1_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem/assessment#XXX-YYYYYYYYYYYY-Z_") // invalid token in URL fragment
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validAssessmentURL_withInvalidFragment2_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem/assessment#Xsdfsdf") // invalid token in URL fragment
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validAssessmentURL_alternativeSpelling_withValidFragment_inHolderApp_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem-assessment#XXX-STXT2VF3389TJ2-Z2")
		
		let expected = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validAssessmentURL_alternativeSpelling_withValidFragment_inHolderApp_withLunhCheckDisabled_doesNotPassLunhCheck_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem-assessment#XXX-YYYYYYYYYYYY-Z2")
		
		let expected = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "YYYYYYYYYYYY",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: false)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validAssessmentURL_alternativeSpelling_withValidFragment_inHolderApp_withLunhCheckEnsabled_doesNotPassLunhCheck_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem-assessment#XXX-YYYYYYYYYYYY-Z2")
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validAssessmentURL_alternativeSpelling_inVerifierApp_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem-assessment#XXX-YYYYYYYYYYYY-Z2")
		
		let link = UniversalLink(userActivity: activity, appFlavor: .verifier, isLunhCheckEnabled: true)
		
		XCTAssertNil(link)
	}
	
	func test_validAssessmentURL_alternativeSpelling_withInvalidFragment1_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem-assessment#XXX-YYYYYYYYYYYY-Z_") // invalid token in URL fragment
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validAssessmentURL_alternativeSpelling_withInvalidFragment2_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem-assessment#Xsdfsdf") // invalid token in URL fragment
		
		// Act
		let link = UniversalLink(userActivity: activity, appFlavor: .holder, isLunhCheckEnabled: true)
		
		// Assert
		expect(link) == nil
	}
}
