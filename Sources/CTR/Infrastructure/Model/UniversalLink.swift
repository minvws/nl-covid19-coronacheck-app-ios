/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum UniversalLink {
    case redeemHolderToken(requestToken: RequestToken)

    init?(userActivity: NSUserActivity) {
        // Only the holder app currently supports universal links
        guard AppFlavor.flavor == .holder else { return nil }

        guard
            let url = userActivity.webpageURL,
            url.path == "/app/redeem",
            let fragment = url.fragment
        else {
            return nil
        }

        // TODO should we check `userActivity.activityType == NSUserActivityTypeBrowsingWeb`?

        guard let requestToken = RequestToken(input: fragment) else {
            return nil
        }

        self = .redeemHolderToken(requestToken: requestToken)
    }
}
