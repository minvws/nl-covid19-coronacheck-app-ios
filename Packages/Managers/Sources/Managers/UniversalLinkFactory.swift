/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models
import Shared
import Transport

public final class UniversalLinkFactory {
	
	public static func create(userActivity: NSUserActivity, featureFlagManager: FeatureFlagManaging, appFlavor: AppFlavor = .flavor) -> UniversalLink? {
		
		// Apple's docs specify to only handle universal links "with the activityType set to NSUserActivityTypeBrowsingWeb"
		guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
			  let url = userActivity.webpageURL
		else { return nil }
		
		switch appFlavor {
			case .holder:
				return HolderUniversalLinkFactory().create(url: url, featureFlagManager: featureFlagManager)
			case .verifier:
				return VerifierUniversalLinkFactory().create(url: url)
		}
	}
}

public final class HolderUniversalLinkFactory {
	
	public func create(url: URL, featureFlagManager: FeatureFlagManaging) -> UniversalLink? {
		
		if url.path == "/app/redeem", let fragment = url.fragment {
			
			guard let requestToken = createRequestToken(fragment: fragment, featureFlagManager: featureFlagManager) else { return nil }
			return UniversalLink.redeemHolderToken(requestToken: requestToken)
		} else if (url.path == "/app/redeem/assessment" || url.path == "/app/redeem-assessment"), let fragment = url.fragment {
			
			guard let requestToken = createRequestToken(fragment: fragment, featureFlagManager: featureFlagManager) else { return nil }
			return UniversalLink.redeemVaccinationAssessment(requestToken: requestToken)
		} else if url.path == "/app/open" {
			
			return UniversalLink.thirdPartyTicketApp(returnURL: createReturnURL(for: url))
		} else if url.path.hasPrefix("/app/auth") {
			
			// Currently '/app/auth2' path is in use
			return .tvsAuth(returnURL: url)
		}
		return nil
	}
	
	public func createRequestToken(fragment: String, featureFlagManager: FeatureFlagManaging) -> RequestToken? {
		
		let tokenValidator = TokenValidator(isLuhnCheckEnabled: featureFlagManager.isLuhnCheckEnabled())
		return RequestTokenFactory.create(input: fragment, tokenValidator: tokenValidator)
	}
}

public final class VerifierUniversalLinkFactory {
	
	public func create(url: URL) -> UniversalLink? {
		
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
