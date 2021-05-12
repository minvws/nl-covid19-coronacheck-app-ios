/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RemoteConfigManaging {

	/// Initialize
	init()

	/// The current app version
	var appVersion: String { get }

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (LaunchState) -> Void)

	/// Get the configuration
	/// - Returns: the remote configuration
	func getConfiguration() -> RemoteConfiguration

	func reset()
}

/// The remote configuration manager
class RemoteConfigManager: RemoteConfigManaging, Logging {

	/// Category for logging
	let loggingCategory = "RemoteConfigManager"

	private struct Constants {
		static let keychainService = "RemoteConfigManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// The current app version supplier
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()

	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager

	/// The current app version
	var appVersion: String {

		versionSupplier.getCurrentVersion()
	}

	/// Persist the remote configuration in the keychain
	@Keychain(name: "storedConfiguration", service: Constants.keychainService, clearOnReinstall: false)
	private var storedConfiguration: RemoteConfiguration = .default

	@UserDefaults(key: "lastFetchedTimestamp", defaultValue: nil)
	var lastFetchedTimestamp: Date? // swiftlint:disable:this let_var_whitespace

	/// Initialize
	required init() {

		// Required by protocol
	}

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (LaunchState) -> Void) {

		networkManager.getRemoteConfiguration { [weak self] resultwrapper in

			self?.handleResultWrapper(resultwrapper, completion: completion)
		}
	}

	/// Handle the resultwrapper response from the get remote configuration call
	/// - Parameters:
	///   - resultWrapper: the result wrapper
	///   - completion: completion handler
	private func handleResultWrapper(
		_ resultWrapper: Result<RemoteConfiguration, NetworkError>,
		completion: @escaping (LaunchState) -> Void) {

		switch resultWrapper {
			case let .success(remoteConfiguration):
				// Update the last fetch time
				lastFetchedTimestamp = Date()
				// Persist the remote configuration
				storedConfiguration = remoteConfiguration
				// Decide what to do
				compare(remoteConfiguration, completion: completion)

			case let .failure(networkError):

				// Fallback to the last known remote configuration
				logError("Error retreiving remote configuration: \(networkError.localizedDescription)")
				logDebug("Using stored Configuration \(storedConfiguration)")

				if let lastFetchedTimestamp = lastFetchedTimestamp,
				   lastFetchedTimestamp > Date() - TimeInterval(storedConfiguration.configTTL ?? 0) {
					// We still got a remote configuration within the config TTL.
					logInfo("Remote Configuration still within TTL")
					compare(storedConfiguration, completion: completion)
				} else {
					compare(storedConfiguration) { state in
						switch state {
							case .actionRequired:
								// Deactiviated or update trumps no internet
								completion(state)
							default:
								completion(.internetRequired)
						}
					}
				}
		}
	}

	/// Compare the remote configuration against the app version
	/// - Parameters:
	///   - remoteConfiguration: the remote configuration
	///   - completion: completion handler
	private func compare(
		_ remoteConfiguration: AppVersionInformation,
		completion: @escaping (LaunchState) -> Void) {

		let requiredVersion = fullVersionString(remoteConfiguration.minimumVersion)
		let currentVersion = fullVersionString(self.appVersion)

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

	/// Get the configuration
	/// - Returns: the remote configuration
	func getConfiguration() -> RemoteConfiguration {

		return storedConfiguration
	}

	func reset() {

		storedConfiguration = .default
	}
}
