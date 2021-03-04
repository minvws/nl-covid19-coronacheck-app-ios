/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class Configuration {

	/// Dictionary with DigiD configs
	var digid: NSDictionary = [:]

	/// Dictionary with General configs
	var general: NSDictionary = [:]

	/// Initlializer
	init() {

		let plistPath: String?

		if let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String {
			if networkConfigurationValue.lowercased() == "production" {
				plistPath = Bundle.main.path(forResource: "configuration-production", ofType: "plist")
			} else if networkConfigurationValue.lowercased() == "acc" {
				plistPath = Bundle.main.path(forResource: "configuration-acceptance", ofType: "plist")
			} else {
				plistPath = Bundle.main.path(forResource: "configuration-development", ofType: "plist")
			}
		} else {
			// Fallback to development
			plistPath = Bundle.main.path(forResource: "configuration-development", ofType: "plist")
		}

		if let path = plistPath, let dictionary = NSDictionary(contentsOfFile: path) {
			if let apiDict = dictionary["digid"] as? NSDictionary {
				digid = apiDict
			}

			if let apiDict = dictionary["general"] as? NSDictionary {
				general = apiDict
			}
		}
	}

	func getEnvironment() -> String {

		if let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String {
			return networkConfigurationValue.lowercased()
		} else {
			return "test"
		}
	}
}
