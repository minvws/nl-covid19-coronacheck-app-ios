//
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
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")

        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        let expected = UniversalLink.redeemHolderToken(requestToken: RequestToken(
            token: "YYYYYYYYYYYY",
            protocolVersion: "2.0",
            providerIdentifier: "XXX"
        ))
        XCTAssertEqual(link, expected)
    }

    func test_validHolderURL_inVerifierApp_doesNotCreateLink() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z2")

        let link = UniversalLink(userActivity: activity, appFlavor: .verifier)

        XCTAssertNil(link)
    }

    func test_validHolderURL_withInvalidFragment1_doesNotCreateLink() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#XXX-YYYYYYYYYYYY-Z_") //invalid token in URL fragment

        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        XCTAssertNil(link)
    }

    func test_validHolderURL_withInvalidFragment2_doesNotCreateLink() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = URL(string: "http://coronatest.nl/app/redeem#Xsdfsdf") //invalid token in URL fragment

        let link = UniversalLink(userActivity: activity, appFlavor: .holder)

        XCTAssertNil(link)
    }
}
