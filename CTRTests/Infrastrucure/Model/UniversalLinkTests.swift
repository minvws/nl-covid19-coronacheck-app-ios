/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR

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
        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        // Assert
        XCTAssertEqual(link, expected)
    }

    func test_validHolderURL_inVerifierApp_doesNotCreateLink() {

        // Arrange
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")

        let link = UniversalLink(userActivity: activity, appFlavor: .verifier)

        XCTAssertNil(link)
    }

    func test_validHolderURL_withInvalidFragment1_doesNotCreateLink() {

        // Arrange
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z_") // invalid token in URL fragment

        // Act
        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        // Assert
        XCTAssertNil(link)
    }

    func test_validHolderURL_withInvalidFragment2_doesNotCreateLink() {

        // Arrange
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#Xsdfsdf") // invalid token in URL fragment

        // Act
        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        // Assert
        XCTAssertNil(link)
    }

    func test_rejectsUserActivity_ifNotOfType_NSUserActivityTypeBrowsingWeb() {

        // Arrange
        let activity = NSUserActivity(activityType: "Other")
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")

        // Act
        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        // Assert
        XCTAssertNil(link)
    }
}
