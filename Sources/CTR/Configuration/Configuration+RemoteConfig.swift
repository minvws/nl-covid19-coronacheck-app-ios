/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationRemoteConfigProtocol {

	/// Get the remote config host
	/// - Returns: the remote config
	func getRemoteConfigHost() -> String

	/// Get the remote config endpoint
	/// - Returns: the remote config endpoint
	func getRemoteConfigEndpoint() -> String
}

extension Configuration: ConfigurationRemoteConfigProtocol {

	/// Get the remote config host
	/// - Returns: the remote config
	func getRemoteConfigHost() -> String {
		guard let value = remoteConfig["host"] as? String else {
			fatalError("Configuration: No remote config host provided")
		}
		return value
	}

	/// Get the remote config endpoint
	/// - Returns: the remote config endpoint
	func getRemoteConfigEndpoint() -> String {
		guard let value = remoteConfig["configEndpoint"] as? String else {
			fatalError("Configuration: No remote config endpoint provided")
		}
		return value
	}
}
