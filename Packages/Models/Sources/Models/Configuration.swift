/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public class Configuration {
	
	public enum Release: String {
		case production
		case acceptance = "acc"
		case test
		case development = "dev"
	}

	/// Dictionary with DigiD configs
	public var digid: NSDictionary = [:]
	
	/// Dictionary with GGD Portal configs
	public var ggdPortal: NSDictionary = [:]

	/// Dictionary with General configs
	public var general: NSDictionary = [:]

	/// Initlializer
	public init() {

		let plistPath: String?
		
		switch getRelease() {
			case .production:
				plistPath = Bundle.main.path(forResource: "configuration-production", ofType: "plist")
			case .acceptance:
				plistPath = Bundle.main.path(forResource: "configuration-acceptance", ofType: "plist")
			case .test:
				plistPath = Bundle.main.path(forResource: "configuration-test", ofType: "plist")
			case .development:
				plistPath = Bundle.main.path(forResource: "configuration-development", ofType: "plist")
		}

		if let path = plistPath, let dictionary = NSDictionary(contentsOfFile: path) {
			if let apiDict = dictionary["digid"] as? NSDictionary {
				digid = apiDict
			}

			if let apiDict = dictionary["general"] as? NSDictionary {
				general = apiDict
			}
			
			if let apiDict = dictionary["ggdPortal"] as? NSDictionary {
				ggdPortal = apiDict
			}
		}
	}
	
	public func getRelease() -> Release {

		guard let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String else { return .test }
		guard let release = Release(rawValue: networkConfigurationValue.lowercased()) else { return .test }
		return release
	}
}
