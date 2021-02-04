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

	/// Initlializer
	init() {

		let plistPath: String? = Bundle.main.path(forResource: "configuration-development", ofType: "plist")

		if let path = plistPath, let dictionary = NSDictionary(contentsOfFile: path) {
			if let apiDict = dictionary["digid"] as? NSDictionary {
				digid = apiDict
			}
		}
	}
}
