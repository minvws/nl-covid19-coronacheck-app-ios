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
}

protocol LaunchStateDelegate: AnyObject {
	
	func cryptoLibDidNotInitialize()
	
	func appIsDeactivated()
	
	func updateIsRequired(appStoreUrl: URL)
	
	func updateIsRecommended(version: String, appStoreUrl: URL)
	
//	func onServerError(errors: [ServerError])
	
	func onStartApplication()
}

final class LaunchStateManager: LaunchStateManaging {
	typealias DelegateToken = UUID
	
	private var remoteConfigManagerObserverTokens = [RemoteConfigManager.ObserverToken]()
	private let versionSupplier: AppVersionSupplierProtocol
	private var applicationStarted = false
	private var launchStateDelegates = [DelegateToken: LaunchStateDelegate]()
	
	/// Initiializer
	/// - Parameters:
	///   - versionSupplier: the version supplier
	init(versionSupplier: AppVersionSupplierProtocol) {
		
		self.versionSupplier = versionSupplier
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
	
//	func handleLaunchState(
//		_ state: LaunchState,
//		onCryptoError: (() -> Void)?,
//		onDeactivated: (() -> Void)?,
//		onRequiredUpdate: ((URL) -> Void)?,
//		onRecommendedUpdate: ((String, URL) -> Void)?,
//		onStartApplication: (() -> Void)?) {
//
		guard Current.cryptoLibUtility.isInitialized else {
			launchStateDelegates.values.forEach { delegate in
				delegate.cryptoLibDidNotInitialize()
			}
			return
		}

		switch state {
			case .finished:
				break

			case .serverError(let serviceErrors):
				break

			case .withinTTL:
				// If within the TTL, and the firstUseDate is nil, that means an existing installation.
				// Use the documents directory creation date.
				Current.appInstalledSinceManager.update(dateProvider: FileManager.default)
			}
		
			checkRemoteConfiguration(
				Current.remoteConfigManager.storedConfiguration,
				onDeactivated: {
					self.launchStateDelegates.values.forEach { $0.appIsDeactivated() }
				},
				onRequiredUpdate: { url in
					self.launchStateDelegates.values.forEach { $0.updateIsRequired(appStoreUrl: url) }
				},
				onRecommendedUpdate: { version, url in
					self.launchStateDelegates.values.forEach { $0.updateIsRecommended(version: version, appStoreUrl: url) }
				},
				onNoActionNeeded: {
					if !self.applicationStarted {
						self.applicationStarted = true
						self.launchStateDelegates.values.forEach { $0.onStartApplication() }
					}
				}
			)
//
//		//		switch state {
//
//		//
//		//			case .noActionNeeded:
//		//				startApplication()
//		//
//		//			case .internetRequired:
//		//				showInternetRequired()
//		//
		
	}
	
	private func checkRemoteConfiguration(
		_ remoteConfiguration: RemoteConfiguration,
		onDeactivated: (() -> Void)?,
		onRequiredUpdate: ((URL) -> Void)?,
		onRecommendedUpdate: ((String, URL) -> Void)?,
		onNoActionNeeded: (() -> Void)?
	) {
	
		let requiredVersion = remoteConfiguration.minimumVersion.fullVersionString()
		let recommendedVersion = remoteConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier.getCurrentVersion().fullVersionString()

		if remoteConfiguration.isDeactivated {
			onDeactivated?()
		} else if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
			let url = remoteConfiguration.appStoreURL {
			onRequiredUpdate?(url)
		} else if recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
			let url = remoteConfiguration.appStoreURL {
			onRecommendedUpdate?(recommendedVersion, url)
		} else {
			onNoActionNeeded?()
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
			
			self?.updateFromUrlResponse(urlResponse)
		}]
	}
	
	// Update the  managers with the values from the actual http response
	/// - Parameter urlResponse: the url response from the config call
	private func updateFromUrlResponse(_ urlResponse: URLResponse) {
		
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
