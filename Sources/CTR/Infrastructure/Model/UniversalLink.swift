/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum UniversalLink: Equatable {
    case redeemHolderToken(requestToken: RequestToken)

    init?(userActivity: NSUserActivity, appFlavor: AppFlavor = .flavor) {

        // Apple's docs specify to only handle universal links "with the activityType set to NSUserActivityTypeBrowsingWeb"
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return nil }

        // Only the holder app currently supports universal links
        guard appFlavor == .holder else { return nil }

        guard
            let url = userActivity.webpageURL,
            url.path == "/app/redeem",
            let fragment = url.fragment
        else {
            return nil
        }

        guard let requestToken = RequestToken(input: fragment) else {
            return nil
        }

        self = .redeemHolderToken(requestToken: requestToken)
    }
}
