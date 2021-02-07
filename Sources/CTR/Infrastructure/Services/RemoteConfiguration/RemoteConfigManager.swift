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
		// Default to 1.0.0
		return "1.0.0"
	}
}

/// The remote configuration mananger
class RemoteConfigManager: RemoteConfigManaging, Logging {

	/// Category for logging
	let loggingCategory = "RemoteConfigManager"

	private struct Constants {
		static let keychainService = "RemoteConfigManager\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// The current app version supplier
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()

	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager

	/// The current app version
	var appVersion: String {

		return versionSupplier.getCurrentVersion()
	}

	/// Persist the remote configuration in the keychain
	@Keychain(name: "storedConfiguration", service: Constants.keychainService, clearOnReinstall: false)
	private var storedConfiguration: RemoteConfiguration = .default

	/// Initialize
	required init() {

		// Required by protocol
	}

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (UpdateState) -> Void) {

		networkManager.getRemoteConfiguration { [weak self] resultwrapper in

			guard let strongSelf = self else {
				return
			}

			switch resultwrapper {
				case let .success(remoteConfiguration):
					// Persist the remote configuration
					strongSelf.storedConfiguration = remoteConfiguration
					// Decide what to do
					strongSelf.compare(remoteConfiguration, completion: completion)

				case let .failure(networkError):
					// Fallback to the last known remote configuration
					strongSelf.logError("Error retreiving remote configuration: \(networkError.localizedDescription)")
					strongSelf.logDebug("Using stored Configuration \(strongSelf.storedConfiguration)")
					// Decide what to do
					strongSelf.compare(strongSelf.storedConfiguration, completion: completion)
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
			// Update the app
			completion(.actionRequired(remoteConfiguration))
		} else if remoteConfiguration.isDeactivated {
			// Kill the app
			completion(.actionRequired(remoteConfiguration))
		} else {
			// Nothing to do
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
