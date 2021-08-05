/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RemoteConfigManaging: AnyObject {

	/// Initialize
	init(networkManager: NetworkManaging?)

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (Result<(RemoteConfiguration, Data), NetworkError>) -> Void)

	/// Get the configuration
	/// - Returns: the remote configuration
	func getConfiguration() -> RemoteConfiguration

	func reset()
}

/// The remote configuration manager
class RemoteConfigManager: RemoteConfigManaging {

	private struct Constants {
		static let keychainService = "RemoteConfigManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// The network manager
	private weak var networkManager: NetworkManaging?

	/// Persist the remote configuration in the keychain
	@Keychain(name: "storedConfiguration", service: Constants.keychainService, clearOnReinstall: false)
	private var storedConfiguration: RemoteConfiguration = .default

	/// Initialize
	required init(networkManager: NetworkManaging? = Services.networkManager) {

		self.networkManager = networkManager
	}

	/// Update the remote configuration
	/// - Parameter completion: completion handler
	func update(completion: @escaping (Result<(RemoteConfiguration, Data), NetworkError>) -> Void) {
		
		networkManager?.getRemoteConfiguration { [weak self] resultWrapper in
			
			if case .success((let remoteConfiguration, _)) = resultWrapper {
				self?.storedConfiguration = remoteConfiguration
			}
			completion(resultWrapper)
		}
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
