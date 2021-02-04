/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// - Tag: RemoteConfigManaging
protocol RemoteConfigManaging {

	/// Initialize
	init()

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

	/// Get the current version number of the app
	/// - Returns: the current version number
	func getCurrentVersion() -> String {

		if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return version
		}
		return "1.0.0"
	}
}

/// The remote configuration mananger
class RemoteConfigManager: RemoteConfigManaging, Logging {

	/// Category for logging
	let loggingCategory = "RemoteConfigManager"

	/// The current app version supplier
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()

	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager

	/// The current app version
	var appVersion: String {

		return versionSupplier.getCurrentVersion()
	}

	required init() {

		// Required by protocol
	}

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (UpdateState) -> Void) {

		networkManager.getRemoteConfiguration { [weak self] resultwrapper in

			switch resultwrapper {
				case let .success(remoteConfiguration):
					self?.compare(remoteConfiguration, completion: completion)

				case let .failure(networkError):
					self?.logError("Error retreiving remote configuration: \(networkError.localizedDescription)")
					completion(.noActionNeeded)
			}
		}
	}

	/// Compare the remote configuration against the app version
	/// - Parameters:
	///   - remoteConfiguration: the remote confiiguration
	///   - completion: completion handler
	private func compare(
		_ remoteConfiguration: AppVersionInformation,
		completion: @escaping (UpdateState) -> Void) {

		let requiredVersion = fullVersionString(remoteConfiguration.minimumVersion)
		let currentVersion = fullVersionString(self.appVersion)

		logDebug("Updated remote configuration: \(remoteConfiguration)")

		if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
			completion(.actionRequired(remoteConfiguration))
		} else if remoteConfiguration.isDeactivated {
			completion(.actionRequired(remoteConfiguration))
		} else {
			completion(.noActionNeeded)
		}
	}

	/// Get a three digit string of the version
	/// - Parameter version: the version
	/// - Returns: three digit string of the version
	private func fullVersionString(_ version: String) -> String {

		var components = version.split(separator: ".")
		let missingComponents = max(0, 3 - components.count)
		components.append(contentsOf: Array(repeating: "0", count: missingComponents))
		return components.joined(separator: ".")
	}
}
