/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol LaunchStateManaging {
	
	func handleLaunchState(
		_ state: LaunchState,
		onCryptoError: (() -> Void)?,
		onDeactivated: (() -> Void)?,
		onRequiredUpdate: ((URL) -> Void)?,
		onRecommendedUpdate: ((String, URL) -> Void)?,
		onStartApplication: (() -> Void)?)
}

final class LaunchStateManager: LaunchStateManaging {
	
	private var remoteConfigManagerObserverTokens = [RemoteConfigManager.ObserverToken]()
	private let versionSupplier: AppVersionSupplierProtocol
	private var applicationStarted = false
	
	init(versionSupplier: AppVersionSupplierProtocol) {
		
		self.versionSupplier = versionSupplier
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverTokens.forEach {
			Current.remoteConfigManager.removeObserver(token: $0)
		}
	}
	
	// MARK: - Launch State -
	
	func handleLaunchState(
		_ state: LaunchState,
		onCryptoError: (() -> Void)?,
		onDeactivated: (() -> Void)?,
		onRequiredUpdate: ((URL) -> Void)?,
		onRecommendedUpdate: ((String, URL) -> Void)?,
		onStartApplication: (() -> Void)?) {
			
		guard Current.cryptoLibUtility.isInitialized else {
			onCryptoError?()
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
				onDeactivated: onDeactivated,
				onRequiredUpdate: onRequiredUpdate,
				onRecommendedUpdate: onRecommendedUpdate,
				onNoActionNeeded: {
					if !self.applicationStarted {
						self.applicationStarted = true
						onStartApplication?()
					}
				}
			)
			
		//		switch state {

		//
		//			case .noActionNeeded:
		//				startApplication()
		//
		//			case .internetRequired:
		//				showInternetRequired()
		//
		
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
