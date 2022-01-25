/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol LaunchStateManaging {
	typealias DelegateToken = LaunchStateManager.DelegateToken
	
	func handleLaunchState(_ state: LaunchState)
	
	func addDelegate(_ delegate: LaunchStateDelegate) -> DelegateToken
	
	func removeDelegate(token: DelegateToken)
	
	var versionSupplier: AppVersionSupplierProtocol { get set }
}

protocol LaunchStateDelegate: AnyObject {
	
	func appIsDeactivated()

	func cryptoLibDidNotInitialize()
		
	func errorWhileLoading(errors: [ServerError])
	
	func onStartApplication()
	
	func updateIsRequired(appStoreUrl: URL)
	
	func updateIsRecommended(version: String, appStoreUrl: URL)
}

final class LaunchStateManager: LaunchStateManaging {
	typealias DelegateToken = UUID
	
	private var remoteConfigManagerObserverTokens = [RemoteConfigManager.ObserverToken]()
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()
	private var applicationStarted = false
	private var launchStateDelegates = [DelegateToken: LaunchStateDelegate]()
	
	/// Initiializer
	init() {
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverTokens.forEach {
			Current.remoteConfigManager.removeObserver(token: $0)
		}
	}
	
	func addDelegate(_ delegate: LaunchStateDelegate) -> DelegateToken {
		
		let newToken = DelegateToken()
		launchStateDelegates[newToken] = delegate
		return newToken
	}
	
	func removeDelegate(token: DelegateToken) {
		
		launchStateDelegates[token] = nil
	}
	
	// MARK: - Launch State -
	
	func handleLaunchState(_ state: LaunchState) {
	
		guard Current.cryptoLibUtility.isInitialized else {
			launchStateDelegates.values.forEach { delegate in
				delegate.cryptoLibDidNotInitialize()
			}
			return
		}

		switch state {
			case .finished:
				checkRemoteConfiguration(Current.remoteConfigManager.storedConfiguration) {
					self.startApplication()
				}

			case .serverError(let serviceErrors):
				// Deactivated or update trumps no internet or error
				checkRemoteConfiguration(Current.remoteConfigManager.storedConfiguration) {
					self.launchStateDelegates.values.forEach { delegate in
						delegate.errorWhileLoading(errors: serviceErrors)
					}
				}

			case .withinTTL:
				// If within the TTL, and the firstUseDate is nil, that means an existing installation.
				// Use the documents directory creation date.
				Current.appInstalledSinceManager.update(dateProvider: FileManager.default)
				
				checkRemoteConfiguration(Current.remoteConfigManager.storedConfiguration) {
					self.startApplication()
				}
			}
	}
	
	private func startApplication() {
		if !self.applicationStarted {
			self.applicationStarted = true
			self.launchStateDelegates.values.forEach { $0.onStartApplication() }
		}
	}
	
	private func checkRemoteConfiguration(_ remoteConfiguration: RemoteConfiguration, onContinue: (() -> Void)?) {
	
		let requiredVersion = remoteConfiguration.minimumVersion.fullVersionString()
		let recommendedVersion = remoteConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier.getCurrentVersion().fullVersionString()

		if remoteConfiguration.isDeactivated {
			
			self.launchStateDelegates.values.forEach { $0.appIsDeactivated() }
		} else if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
			let url = remoteConfiguration.appStoreURL {
			
			self.launchStateDelegates.values.forEach { $0.updateIsRequired(appStoreUrl: url) }
		} else if recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
			let url = remoteConfiguration.appStoreURL {
			
			self.launchStateDelegates.values.forEach { $0.updateIsRecommended(version: recommendedVersion, appStoreUrl: url) }
		} else {
			
			onContinue?()
		}
	}
	
	// MARK: - Remote Config -
	
	private func configureRemoteConfigManager() {
		
		// Attach behaviours that we want the RemoteConfigManager to perform
		// each time it refreshes the config in future:
		
		remoteConfigManagerObserverTokens += [Current.remoteConfigManager.appendUpdateObserver { _, rawData, _ in

			// Update the remote config for the crypto library
			Current.cryptoLibUtility.store(rawData, for: .remoteConfiguration)
		}]
		
		remoteConfigManagerObserverTokens += [Current.remoteConfigManager.appendReloadObserver {[weak self] _, _, urlResponse in

			// Mark remote config loaded
			Current.cryptoLibUtility.checkFile(.remoteConfiguration)
			
			// Update the server Date handlers
			self?.updateServerDate(urlResponse)
			
			// Recheck the config
			self?.checkRemoteConfiguration(Current.remoteConfigManager.storedConfiguration) {
				self?.startApplication()
			}
		}]
	}
	
	// Update the  managers with the values from the actual http response
	/// - Parameter urlResponse: the url response from the config call
	private func updateServerDate(_ urlResponse: URLResponse) {
		
		/// Fish for the server Date in the network response, and use that to maintain
		/// a clockDeviationManager to check if the delta between the serverTime and the localTime is
		/// beyond a permitted time interval.
		guard let httpResponse = urlResponse as? HTTPURLResponse,
			  let serverDateString = httpResponse.allHeaderFields["Date"] as? String else { return }
		
		Current.clockDeviationManager.update(
			serverHeaderDate: serverDateString,
			ageHeader: httpResponse.allHeaderFields["Age"] as? String
		)
		
		// If the firstUseDate is nil, and we get a server header, that means a new installation.
		Current.appInstalledSinceManager.update(
			serverHeaderDate: serverDateString,
			ageHeader: httpResponse.allHeaderFields["Age"] as? String
		)
	}
}
