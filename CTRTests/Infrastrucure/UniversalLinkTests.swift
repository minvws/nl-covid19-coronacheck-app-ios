/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import XCTest
@testable import CTR
import Nimble
import TestingShared

class UniversalLinkTests: XCTestCase {
	
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_validHolderURL_withValidFragment_inHolderApp_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-STXT2VF3389TJ2-Z2")
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = true
		
		let expected = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .holder)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validHolderURL_withValidFragment_inHolderApp_withLunhCheckDisabled_doesNotPassLunhCheck_createsLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = false
		
		let expected = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "YYYYYYYYYYYY",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// Act
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .holder)
		
		// Assert
		expect(link) == expected
	}
	
	func test_validHolderURL_withValidFragment_inHolderApp_withLunhCheckEnsabled_doesNotPassLunhCheck_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = true
		
		// Act
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .holder)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validHolderURL_inVerifierApp_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = true
		
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .verifier)
		
		XCTAssertNil(link)
	}
	
	func test_validHolderURL_withInvalidFragment1_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z_") // invalid token in URL fragment
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = true
		
		// Act
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .holder)
		
		// Assert
		expect(link) == nil
	}
	
	func test_validHolderURL_withInvalidFragment2_doesNotCreateLink() {
		
		// Arrange
		let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#Xsdfsdf") // invalid token in URL fragment
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = true
		
		// Act
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .holder)
		
		// Assert
		expect(link) == nil
	}
	
	func test_rejectsUserActivity_ifNotOfType_NSUserActivityTypeBrowsingWeb() {
		
		// Arrange
		let activity = NSUserActivity(activityType: "Other")
		activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")
		environmentSpies.featureFlagManagerSpy.stubbedIsLuhnCheckEnabledResult = true
		
		// Act
		let link = UniversalLinkFactory.create(userActivity: activity, featureFlagManager: environmentSpies.featureFlagManagerSpy, appFlavor: .holder)
		
		// Assert
		expect(link) == nil
	}
}
