/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationDigidProtocol {

	/// Get the digid host
	/// - Returns: the digid host
	func getDigidHost() -> String

	/// Get the authorization url for DigiD
	/// - Returns: the authorization url for Digid
	func getAuthorizationURL() -> URL

	/// Get the token url for DigiD
	/// - Returns: the token url for Digid
	func getTokenURL() -> URL

	/// Get the consumer ID for DigiD
	/// - Returns: the consumer ID for DigiD
	func getConsumerId() -> String

	/// Get the redirect uri for Digid
	/// - Returns: the redirect uri for Digid
	func getRedirectUri() -> URL
}

extension Configuration: ConfigurationDigidProtocol {

	/// Get the digid host
	/// - Returns: the digid host
	func getDigidHost() -> String {
		guard let value = digid["host"] as? String else {
			fatalError("Configuration: No DigiD host provided")
		}
		return value
	}

	/// Get the authorization url for DigiD
	/// - Returns: the authorization url for Digid
	func getAuthorizationURL() -> URL {

		guard let value = digid["authorizationEndpoint"] as? String,
			  let url = URL(string: getDigidHost() + value) else {
			fatalError("Configuration: No DigiD Authorization url provided")
		}
		return url
	}

	/// Get the token url for DigiD
	/// - Returns: the token url for Digid
	func getTokenURL() -> URL {

		guard let value = digid["tokenEndpoint"] as? String,
			  let url = URL(string: getDigidHost() + value) else {
			fatalError("Configuration: No DigiD Token url provided")
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
