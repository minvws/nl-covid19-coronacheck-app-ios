/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum UniversalLink: Equatable {
	
    case redeemHolderToken(requestToken: RequestToken)
	case thirdPartyTicketApp(returnURL: URL?)
	case tvsAuth(returnURL: URL?)
	case thirdPartyScannerApp(returnURL: URL?)

	init?(userActivity: NSUserActivity, appFlavor: AppFlavor = .flavor, isLunhCheckEnabled: Bool) {

        // Apple's docs specify to only handle universal links "with the activityType set to NSUserActivityTypeBrowsingWeb"
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
			  let url = userActivity.webpageURL
		else { return nil }
		
		// e.g. `/app/open?returnUri=customScheme%3A%2F%2Fmyreturnurl%2Fpath%2F%3Fsome%3Dquery%23anchor`
		let createReturnURL = { (url: URL) -> URL? in
			guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
			guard let returnURLString = components.queryItems?.first(where: { $0.name == "returnUri" })?.value else { return nil }
			return URL(string: returnURLString)
		}

		if appFlavor == .holder {
			
			if url.path == "/app/redeem", let fragment = url.fragment {
				let tokenValidator = TokenValidator(isLuhnCheckEnabled: isLunhCheckEnabled)
				guard let requestToken = RequestToken(input: fragment, tokenValidator: tokenValidator) else {
					return nil
				}

				self = .redeemHolderToken(requestToken: requestToken)
			} else if url.path == "/app/open" {

				self = .thirdPartyTicketApp(returnURL: createReturnURL(url))
			} else if url.path.hasPrefix("/app/auth") {
				// Currently '/app/auth2' path is in use
				self = .tvsAuth(returnURL: url)
			} else {
				return nil
			}
		} else {
			
			if url.path == "/app/scan" {
				
				self = .thirdPartyScannerApp(returnURL: createReturnURL(url))
			}
			return nil
		}
    }
}
