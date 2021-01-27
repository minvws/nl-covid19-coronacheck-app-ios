/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// - Tag: RemoteConfigManagerProtocol
protocol RemoteConfigManagerProtocol {

	/// The current app version
	var appVersion: String { get }

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (UpdateState) -> Void)
}

/// The version of the app
protocol AppVersionSupplierProtocol {

	/// Get the current version of the app
	func getCurrentVersion() -> String
}

struct AppVersionSupplier: AppVersionSupplierProtocol {

	func getCurrentVersion() -> String {

		if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return version
		}
		return "1.0.0"
	}
}

class RemoteConfigManager: RemoteConfigManagerProtocol, Logging {

	let loggingCategory = "RemoteConfigManager"

	/// The current app version supplier
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()

	/// The current app version
	var appVersion: String {

		return versionSupplier.getCurrentVersion()
	}
	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (UpdateState) -> Void) {
		func fullVersionString(_ version: String) -> String {
			var components = version.split(separator: ".")
			let missingComponents = max(0, 3 - components.count)
			components.append(contentsOf: Array(repeating: "0", count: missingComponents))

			return components.joined(separator: ".")
		}

		RemoteConfigurationApiClient().getRemoteConfiguration { config in
			if let remoteConfig = config {
				let requiredVersion = fullVersionString(remoteConfig.minimumVersion)
				let currentVersion = fullVersionString(self.appVersion)

				self.logDebug("Updated remote configuration: \(remoteConfig)")

				if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
					completion(.updateRequired(remoteConfig))
				} else {
					completion(.noActionNeeded)
//					completion(.updateRequired(remoteConfig))
				}
			} else {
				completion(.noActionNeeded)
			}
		}
	}
}
