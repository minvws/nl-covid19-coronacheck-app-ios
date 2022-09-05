/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability
import UIKit
import Transport

protocol RemoteConfigManaging: AnyObject {
	var storedConfiguration: RemoteConfiguration { get }

	var observatoryForUpdates: Observatory<RemoteConfigManager.ConfigNotification> { get }
	var observatoryForReloads: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>> { get }

	func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: @escaping () -> Void,
		completion: @escaping (Result<(Bool, RemoteConfiguration), ServerError>) -> Void)

	func wipePersistedData()
	
	func registerTriggers()
}

/// The remote configuration manager
class RemoteConfigManager: RemoteConfigManaging {
	typealias ConfigNotification = (RemoteConfiguration, Data, URLResponse)
	
	// MARK: - Vars

	private(set) var isLoading = false

	private(set) var storedConfiguration: RemoteConfiguration {
		get { secureUserSettings.storedConfiguration }
		set { secureUserSettings.storedConfiguration = newValue }
	}

	let observatoryForUpdates: Observatory<RemoteConfigManager.ConfigNotification>
	private let notifyUpdateObservers: (RemoteConfigManager.ConfigNotification) -> Void
	
	let observatoryForReloads: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>
	private let notifyReloadObservers: (Result<RemoteConfigManager.ConfigNotification, ServerError>) -> Void
	
	// MARK: - Dependencies

	private let now: () -> Date
	private let userSettings: UserSettingsProtocol
	private let networkManager: NetworkManaging
	private let reachability: ReachabilityProtocol?
	private let secureUserSettings: SecureUserSettingsProtocol
	private let appVersionSupplier: AppVersionSupplierProtocol
	private let fileStorage: FileStorageProtocol
	
	// MARK: - Setup

	required init(
		now: @escaping () -> Date,
		userSettings: UserSettingsProtocol,
		reachability: ReachabilityProtocol?,
		networkManager: NetworkManaging,
		secureUserSettings: SecureUserSettingsProtocol,
		fileStorage: FileStorageProtocol,
		appVersionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()
	) {

		self.now = now
		self.userSettings = userSettings
		self.reachability = reachability
		self.networkManager = networkManager
		self.secureUserSettings = secureUserSettings
		self.appVersionSupplier = appVersionSupplier
		self.fileStorage = fileStorage
		(self.observatoryForUpdates, self.notifyUpdateObservers) = Observatory<RemoteConfigManager.ConfigNotification>.create()
		(self.observatoryForReloads, self.notifyReloadObservers) = Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>.create()
		
		if let configFromStoredData = fetchConfigFromStoredConfigData(), configFromStoredData != storedConfiguration {
			storedConfiguration = configFromStoredData
		}
	}

	func registerTriggers() {

		NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		}

		reachability?.whenReachable = { [weak self] _ in
			self?.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		}
		try? reachability?.startNotifier()
	}
	
	private func fetchConfigFromStoredConfigData() -> RemoteConfiguration? {
		
		guard let data = fileStorage.read(fileName: CryptoLibUtility.File.remoteConfiguration.name) else { return nil }
		return try? JSONDecoder().decode(RemoteConfiguration.self, from: data)
	}

	// MARK: - Teardown

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: -

	/// Intended for app startup.
	/// Parameters:
	/// 	 - immediateWithinTTLCallback: immediately reports back if the config was within TTL,
	/// 	 so that asynchronous work can be started whilst the request continues.
	///
	/// 	 - completion: 	- Bool: whether the config did change during update.
	///						- RemoteConfiguration: the latest configuration.
	///
	func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: @escaping () -> Void,
		completion: @escaping (Result<(Bool, RemoteConfiguration), ServerError>) -> Void) {
		guard !isLoading else { return }
		isLoading = true

		let newValidity = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: storedConfiguration,
			lastFetchedTimestamp: userSettings.configFetchedTimestamp,
			isAppLaunching: isAppLaunching,
			now: now
		)

		// Special actions per-validity:
		switch newValidity {
			case .neverFetched:
				// Ensure that we're not using a keychain-persisted value from a previous installation:
				storedConfiguration = .default

			case .withinTTL:
				// If already within TTL, immediately trigger special callback
				// so that other app-startup work can begin:
				immediateCallbackIfWithinTTL()

			default: break
		}

		// Note: the `isAppLaunching` parameter is respected in calculating the `newValidity`
		// and thus the `guard` will not trigger during first launch
		//
		// This also means that during first launch, `reloadObservers` will always be called back.
		guard newValidity != .withinMinimalInterval else {
			// Not allowed to call config endpoint again
			immediateCallbackIfWithinTTL()
			completion(.success((false, storedConfiguration)))
			isLoading = false
			return
		}

		// Regardless, let's see if there's a new configuration available:
		networkManager.getRemoteConfiguration { [weak self] (resultWrapper: Result<(RemoteConfiguration, Data, URLResponse), ServerError>) in
			guard let self = self else { return }

			// Note: `handleNetworkResponse` calls completion for us..
			self.handleNetworkResponse(resultWrapper: resultWrapper, completion: completion)
			self.isLoading = false
		}
	}

	private func handleNetworkResponse(
		resultWrapper: Result<(RemoteConfiguration, Data, URLResponse), ServerError>,
		completion: @escaping (Result<(Bool, RemoteConfiguration), ServerError>) -> Void
	) {
		switch resultWrapper {
			case let .failure(serverError):
				notifyReloadObservers(Result.failure(serverError))
				completion(.failure(serverError))

			case let .success((remoteConfiguration, data, urlResponse)):

				// Calculate the new hash
				// It should match the following command (verifier/holder):
				// `curl https://verifier-api.coronacheck.nl/v8/verifier/config | jq -r .payload | base64 -d | sha256sum`
				let newHash: String? = {
					guard let string = String(data: data, encoding: .utf8) else { return nil }
					return string.sha256 + appVersionSupplier.getCurrentBuild() + appVersionSupplier.getCurrentVersion()
				}()

				let hashesMatch = userSettings.configFetchedHash == newHash

				// Save the config & new hash regardless of whether the hashes match,
				// to guard against the keychain value being out of sync with the UserDefaults hash
				userSettings.configFetchedHash = newHash
	
				// Update the last fetch-time
				userSettings.configFetchedTimestamp = now().timeIntervalSince1970
				
				storedConfiguration = remoteConfiguration

				// Some observers want to know whenever the config is reloaded (regardless if data changed since last time):
				self.notifyReloadObservers(Result.success((remoteConfiguration: remoteConfiguration, data: data, response: urlResponse)))
	
				// Is the newly fetched config hash the same as the existing one?
				// Use the hash, as not all of the config values are mapping in the remoteconfig object.
				if hashesMatch {
					completion(.success((false, remoteConfiguration)))
				} else {
					// Inform the observers that only wish to know when config has changed:
					notifyUpdateObservers((remoteConfiguration: remoteConfiguration, data: data, response: urlResponse))
					completion(.success((true, remoteConfiguration)))
				}
		}
	}
}

extension RemoteConfigManager {

	func wipePersistedData() {
		storedConfiguration = .default
	}
}
