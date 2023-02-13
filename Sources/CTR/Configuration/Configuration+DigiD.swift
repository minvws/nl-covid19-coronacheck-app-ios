/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

extension Configuration {

	/// Get the TVS url
	/// - Returns: the tvs url
	func getTVSURL() -> URL {
		guard let value = digid["host"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No TVS url provided")
		}
		return url
	}

	/// Get the consumer ID for DigiD
	/// - Returns: the consumer ID for DigiD
	func getTVSClientId() -> String {

		guard let value = digid["consumerId"] as? String else {
			fatalError("Configuration: No DigiD Consumer Id provided")
		}
		return value
	}

	/// Get the redirect uri for Digid
	/// - Returns: the redirect uri for Digid
	func getTVSRedirectUri() -> URL {

		guard let value = digid["redirectUri"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No DigiD Redirect URL provided")
		}
		return url
	}
}
