/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationProtocol {

	/// Get the host url for the  API
	/// - Returns: the host for the API
	func getAPIHost() -> String

	/// Get the endpoint for the nonce
	/// - Returns: the nonce endpoint
	func getNonceEndpoint() -> String

	/// Get the endpoint for the public keys
	/// - Returns: the public keys endpoint
	func getPublicKeysEndpoint() -> String

	/// Get the endpoint for the test results with ism
	/// - Returns: the test results endpoint
	func getIsmEndpoint() -> String
}

class Configuration: ConfigurationProtocol {

	/// Dictionary with API configs
	var api: NSDictionary = [:]

	/// Dictionary with app update configs
	var remoteConfig: NSDictionary = [:]

	/// Dictionary with DigiD configs
	var digid: NSDictionary = [:]

	/// Initlializer
	init() {

		let plistPath: String? = Bundle.main.path(forResource: "configuration-development", ofType: "plist")

		if let path = plistPath, let dictionary = NSDictionary(contentsOfFile: path) {
			if let apiDict = dictionary["api"] as? NSDictionary {
				api = apiDict
			}
			if let apiDict = dictionary["remoteConfig"] as? NSDictionary {
				remoteConfig = apiDict
			}
			if let apiDict = dictionary["digid"] as? NSDictionary {
				digid = apiDict
			}
		}
	}

	/// Get the host url for the  API
	/// - Returns: the host for the API
	func getAPIHost() -> String {

		guard let value = api["apiHost"] as? String else {
			fatalError("Configuration: No API Host provided")
		}
		return value
	}

	/// Get the endpoint for the nonce
	/// - Returns: the nonce endpoint
	func getNonceEndpoint() -> String {

		guard let value = api["nonceEndpoint"] as? String else {
			fatalError("Configuration: No Nonce Endpoint provided")
		}
		return value
	}

	/// Get the endpoint for the public keys
	/// - Returns: the public keys endpoint
	func getPublicKeysEndpoint() -> String {

		guard let value = api["publicKeysEndpoint"] as? String else {
			fatalError("Configuration: No Public Keys Endpoint provided")
		}
		return value
	}

	/// Get the endpoint for the test results with ism
	/// - Returns: the test results endpoint
	func getIsmEndpoint() -> String {

		guard let value = api["ismEndpoint"] as? String else {
			fatalError("Configuration: No ISM Endpoint provided")
		}
		return value
	}
}
