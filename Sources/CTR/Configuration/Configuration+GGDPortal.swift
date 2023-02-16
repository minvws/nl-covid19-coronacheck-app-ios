/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

extension Configuration {

	/// Get the Portal url
	/// - Returns: the tvs url
	func getPortalURL() -> URL {
		guard let value = ggdPortal["host"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No ggdPortal url provided")
		}
		return url
	}

	/// Get the consumer ID for GGD Portal
	/// - Returns: the client ID for GGD Portal
	func getPortalClientId() -> String {

		guard let value = ggdPortal["clientId"] as? String else {
			fatalError("Configuration: No ggdPortal Client Id provided")
		}
		return value
	}

	/// Get the redirect uri for GGD Portal
	/// - Returns: the redirect uri for GGD Portal
	func getPortalRedirectUri() -> URL {

		guard let value = ggdPortal["redirectUri"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No ggdPortal Redirect URL provided")
		}
		return url
	}
}
