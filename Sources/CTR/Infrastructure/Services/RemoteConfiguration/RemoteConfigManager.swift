/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability
import UIKit

protocol RemoteConfigManaging: AnyObject {
	typealias ObserverToken = RemoteConfigManager.ObserverToken

	var storedConfiguration: RemoteConfiguration { get }

	func appendUpdateObserver(_ observer: @escaping (RemoteConfiguration, Data, URLResponse) -> Void) -> ObserverToken
	func appendReloadObserver(_ observer: @escaping (RemoteConfiguration, Data, URLResponse) -> Void) -> ObserverToken

	func removeObserver(token: ObserverToken)
	func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: @escaping () -> Void,
		completion: @escaping (Result<(Bool, RemoteConfiguration), ServerError>) -> Void)

	func wipePersistedData()
}

/// The remote configuration manager
class RemoteConfigManager: RemoteConfigManaging, Logging {
	typealias ObserverToken = UUID

	// MARK: - Vars

	private(set) var isLoading = false

	private(set) var storedConfiguration: RemoteConfiguration {
		get { secureUserSettings.storedConfiguration }
		set { secureUserSettings.storedConfiguration = newValue }
	}
	private var configUpdateObservers = [ObserverToken: (RemoteConfiguration, Data, URLResponse) -> Void]()
	private var configReloadObservers = [ObserverToken: (RemoteConfiguration, Data, URLResponse) -> Void]()

	// MARK: - Dependencies

	private let now: () -> Date
	private let userSettings: UserSettingsProtocol
	private let networkManager: NetworkManaging
	private let reachability: ReachabilityProtocol?
	private let secureUserSettings: SecureUserSettingsProtocol
	
	// MARK: - Setup

	required init(
		now: @escaping () -> Date,
		userSettings: UserSettingsProtocol,
		reachability: ReachabilityProtocol?,
		networkManager: NetworkManaging,
		secureUserSettings: SecureUserSettingsProtocol
	) {

		self.now = now
		self.userSettings = userSettings
		self.reachability = reachability
		self.networkManager = networkManager
		self.secureUserSettings = secureUserSettings

		checkStoredJson()
		
		registerTriggers()
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
	
	func checkStoredJson() {
		
		if let data = FileStorage().read(fileName: CryptoLibUtility.File.remoteConfiguration.name) {
			do {
				let configFromStoredJson = try JSONDecoder().decode(RemoteConfiguration.self, from: data)
				if configFromStoredJson != storedConfiguration {
					logInfo("Updating from stored json")
					storedConfiguration = configFromStoredJson
				}			} catch {
				logError("Error Deserializing: \(error)")
			}
		}
	}

	// MARK: - Teardown

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - External Observers

	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func appendUpdateObserver(_ observer: @escaping (RemoteConfiguration, Data, URLResponse) -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		configUpdateObservers[newToken] = observer
		return newToken
	}

	func appendReloadObserver(_ observer: @escaping (RemoteConfiguration, Data, URLResponse) -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		configReloadObservers[newToken] = observer
		return newToken
	}

	func removeObserver(token: ObserverToken) {
		configUpdateObservers[token] = nil
		configReloadObservers[token] = nil
	}

	private func notifyUpdateObservers(remoteConfiguration: RemoteConfiguration, data: Data, response: URLResponse) {

		configUpdateObservers.values.forEach { callback in
			callback(remoteConfiguration, data, response)
		}
	}

	private func notifyReloadObservers(remoteConfiguration: RemoteConfiguration, data: Data, response: URLResponse) {

		configReloadObservers.values.forEach { callback in
			callback(remoteConfiguration, data, response)
		}
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
				completion(.failure(serverError))

			case let .success((remoteConfiguration, data, urlResponse)):

				// Update the last fetch-time
				userSettings.configFetchedTimestamp = now().timeIntervalSince1970

				// Some observers want to know whenever the config is reloaded (regardless if data changed since last time):
				self.notifyReloadObservers(remoteConfiguration: remoteConfiguration, data: data, response: urlResponse)

				// Calculate the new hash
				// It should match the following command (verifier/holder):
				// `curl https://verifier-api.acc.coronacheck.nl/v6/verifier/config | jq -r .payload | base64 -d | sha256sum`
				let newHash: String? = {
					guard let string = String(data: data, encoding: .utf8) else { return nil }
					return string.sha256
				}()

				let hashesMatch = userSettings.configFetchedHash == newHash

				// Save the config & new hash regardless of whether the hashes match,
				// to guard against the keychain value being out of sync with the UserDefaults hash
				userSettings.configFetchedHash = newHash
				storedConfiguration = remoteConfiguration

				// Is the newly fetched config hash the same as the existing one?
				// Use the hash, as not all of the config values are mapping in the remoteconfig object.
				if hashesMatch {
					completion(.success((false, remoteConfiguration)))
				} else {
					// Inform the observers that only wish to know when config has changed:
					notifyUpdateObservers(remoteConfiguration: remoteConfiguration, data: data, response: urlResponse)
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
