/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationDigidProtocol: AnyObject {

	/// Get the TVS url
	/// - Returns: the tvs url
	func getTVSURL() -> URL

	/// Get the consumer ID for DigiD
	/// - Returns: the consumer ID for DigiD
	func getConsumerId() -> String

	/// Get the redirect uri for Digid
	/// - Returns: the redirect uri for Digid
	func getRedirectUri() -> URL
}

// MARK: - ConfigurationDigidProtocol

extension Configuration: ConfigurationDigidProtocol {

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
	func getConsumerId() -> String {

		guard let value = digid["consumerId"] as? String else {
			fatalError("Configuration: No DigiD Consumer Id provided")
		}
		return value
	}

	/// Get the redirect uri for Digid
	/// - Returns: the redirect uri for Digid
	func getRedirectUri() -> URL {

		guard let value = digid["redirectUri"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No DigiD Redirect URL provided")
		}
		return url
	}
}
