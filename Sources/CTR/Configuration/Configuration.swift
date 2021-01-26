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

	/// Get the endpoint for the agent
	/// - Returns: the agent endpoint
	func getAgentEndpoint() -> String

	/// Get the endpoint for the event
	/// - Returns: the event endpoint
	func getEventEndpoint() -> String

	/// Get the endpoint for the public keys
	/// - Returns: the public keys endpoint
	func getPublicKeysEndpoint() -> String

	/// Get the endpoint for the test results
	/// - Returns: the test results endpoint
	func getTestResultsEndpoint() -> String
}

class Configuration: ConfigurationProtocol {

	/// Dictionary with API configs
	var api: NSDictionary = [:]

	/// Dictionary with DigiD configs
	var digid: NSDictionary = [:]

	/// Initlializer
	init() {

		let plistPath: String? = Bundle.main.path(forResource: "configuration-development", ofType: "plist")

		if let path = plistPath, let dictionary = NSDictionary(contentsOfFile: path) {
			if let apiDict = dictionary["api"] as? NSDictionary {
				api = apiDict
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

	/// Get the endpoint for the agent
	/// - Returns: the agent endpoint
	func getAgentEndpoint() -> String {

		guard let value = api["agentEndpoint"] as? String else {
			fatalError("Configuration: No Agent Endpoint provided")
		}
		return value
	}

	/// Get the endpoint for the event
	/// - Returns: the event endpoint
	func getEventEndpoint() -> String {

		guard let value = api["eventEndpoint"] as? String else {
			fatalError("Configuration: No Event Endpoint provided")
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

	/// Get the endpoint for the test results
	/// - Returns: the test results endpoint
	func getTestResultsEndpoint() -> String {

		guard let value = api["testresultsEndpoint"] as? String else {
			fatalError("Configuration: No Public Keys Endpoint provided")
		}
		return value
	}
}
