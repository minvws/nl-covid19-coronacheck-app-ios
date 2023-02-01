/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Transport
import Shared

final class UniversalLinkFactory {
	
	static func create(userActivity: NSUserActivity, appFlavor: AppFlavor = .flavor) -> UniversalLink? {
		
		// Apple's docs specify to only handle universal links "with the activityType set to NSUserActivityTypeBrowsingWeb"
		guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
			  let url = userActivity.webpageURL
		else { return nil }
		
		switch appFlavor {
			case .holder:
				return HolderUniversalLinkFactory().create(url: url)
			case .verifier:
				return VerifierUniversalLinkFactory().create(url: url)
		}
	}
}

final class HolderUniversalLinkFactory {
	
	func create(url: URL) -> UniversalLink? {
		
		if url.path == "/app/redeem", let fragment = url.fragment {
			
			guard let requestToken = RequestTokenFactory.create(input: fragment) else { return nil }
			return UniversalLink.redeemHolderToken(requestToken: requestToken)
		} else if (url.path == "/app/redeem/assessment" || url.path == "/app/redeem-assessment"), let fragment = url.fragment {
			
			guard let requestToken = RequestTokenFactory.create(input: fragment) else { return nil }
			return UniversalLink.redeemVaccinationAssessment(requestToken: requestToken)
		} else if url.path == "/app/open" {
			
			return UniversalLink.thirdPartyTicketApp(returnURL: createReturnURL(for: url))
		} else if url.path.hasPrefix("/app/auth") {
			
			// Currently '/app/auth2' path is in use
			return .tvsAuth(returnURL: url)
		}
		return nil
	}
}

final class VerifierUniversalLinkFactory {
	
	func create(url: URL) -> UniversalLink? {
		
		if url.path == "/verifier/scan" {
			return UniversalLink.thirdPartyScannerApp(returnURL: createReturnURL(for: url))
		}
		return nil
	}
}

// e.g. `/app/open?returnUri=customScheme%3A%2F%2Fmyreturnurl%2Fpath%2F%3Fsome%3Dquery%23anchor`
private func createReturnURL(for url: URL) -> URL? {
	
	guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
	guard let returnURLString = components.queryItems?.first(where: { $0.name == "returnUri" })?.value else { return nil }
	return URL(string: returnURLString)
}

final class RequestTokenFactory {
	
	static func create(input: String) -> RequestToken? {
		
		let tokenValidator = TokenValidator(isLuhnCheckEnabled: Current.featureFlagManager.isLuhnCheckEnabled())
		guard tokenValidator.validate(input) else {
			return nil
		}
		
		let parts = input.split(separator: "-")
		guard parts.count >= 2, parts[0].count == 3 else { return nil }
		
		let identifierPart = String(parts[0])
		let tokenPart = String(parts[1])
		return RequestToken(
			token: tokenPart,
			protocolVersion: RequestToken.highestKnownProtocolVersion,
			providerIdentifier: identifierPart
		)
	}
}
