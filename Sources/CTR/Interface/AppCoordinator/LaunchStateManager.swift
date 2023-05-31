/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import Managers
import Models

protocol LaunchStateManaging {
	
	func handleLaunchState(_ state: LaunchState)
	
	func enableRestart()
		
	var delegate: LaunchStateManagerDelegate? { get set }
}

protocol LaunchStateManagerDelegate: AnyObject {
	
	func appIsDeactivated()

	func applicationShouldStart()

	func cryptoLibDidNotInitialize()
		
	func errorWhileLoading(_ errorTuples: [(error: ServerError, step: ErrorCode.Step)])
		
	func updateIsRequired(appStoreUrl: URL)
	
	func updateIsRecommended(version: String, appStoreUrl: URL)
	
	func showPriorityNotification(_ notification: String)
}

final class LaunchStateManager: LaunchStateManaging {
	
	private var remoteConfigManagerUpdateObserverToken: Observatory<RemoteConfigManager.ConfigNotification>.ObserverToken?
	private var remoteConfigManagerReloadObserverToken: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>.ObserverToken?
	
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()
	private var applicationHasStarted = false
	weak var delegate: LaunchStateManagerDelegate?
	
	/// Initiializer
	init() {
		configureRemoteConfigManagerForUpdate()
	}
	
	deinit {
		remoteConfigManagerUpdateObserverToken.map(Current.remoteConfigManager.observatoryForUpdates.remove)
		remoteConfigManagerReloadObserverToken.map(Current.remoteConfigManager.observatoryForReloads.remove)
	}
	
	// MARK: - Launch State -
	
	func handleLaunchState(_ state: LaunchState) {
		
		if LaunchArgumentsHandler.shouldSkipOnboarding() {
			startApplication()
			return
		}
		
		if state == .withinTTL {
			// If within the TTL, and the firstUseDate is nil, that means an existing installation.
			// Use the documents directory creation date.
			Current.appInstalledSinceManager.update(dateProvider: FileManager.default)
		}
		
		checkRemoteConfiguration(Current.remoteConfigManager.storedConfiguration) {
			switch state {
				case .finished, .withinTTL:
					guard Current.cryptoLibUtility.isInitialized else {
						self.delegate?.cryptoLibDidNotInitialize()
						return
					}
					self.startApplication()
				case let .serverError(tuples):
					if !self.applicationHasStarted {
						self.delegate?.errorWhileLoading(tuples)
					}
			}
		}
	}
	
	private func startApplication() {
		
		if !applicationHasStarted {
			// Only start once (we will get called multiple times (withinTTL, finished)
			applicationHasStarted = true
			
			// Only now start listening to remote config changes. Earlier disrupts the launch sequence
			configureRemoteConfigManagerForReload()
			
			// Notify the delegate to start.
			delegate?.applicationShouldStart()
		}
	}
	
	private func checkRemoteConfiguration(_ remoteConfiguration: RemoteConfiguration, onContinue: (() -> Void)?) {
	
		if let priorityNotification = remoteConfiguration.priorityNotification, priorityNotification.isNotEmpty {
			self.delegate?.showPriorityNotification(priorityNotification)
		}
		
		let requiredVersion = remoteConfiguration.minimumVersion.fullVersionString()
		let recommendedVersion = remoteConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier.getCurrentVersion().fullVersionString()

		if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
		   let url = remoteConfiguration.appStoreURL {
			
			self.enableRestart()
			self.delegate?.updateIsRequired(appStoreUrl: url)
		} else if remoteConfiguration.isDeactivated {
			
			self.enableRestart()
			self.delegate?.appIsDeactivated()
		} else if recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
			let url = remoteConfiguration.appStoreURL {
			
			self.delegate?.updateIsRecommended(version: recommendedVersion, appStoreUrl: url)
		} else {
			
			onContinue?()
		}
	}
	
	func enableRestart() {
		
		applicationHasStarted = false
	}
	
	// MARK: - Remote Config -

	private func configureRemoteConfigManagerForUpdate() {
		
		// Attach behaviours that we want the RemoteConfigManager to perform
		// each time it refreshes the config in future:
		
		remoteConfigManagerUpdateObserverToken = Current.remoteConfigManager.observatoryForUpdates.append { _, rawData, _, _ in

			// Update the remote config for the crypto library
			Current.cryptoLibUtility.store(rawData, for: .remoteConfiguration)
		}
	}
	
	private func configureRemoteConfigManagerForReload() {
		
		// Attach behaviours that we want the RemoteConfigManager to perform
		// each time it refreshes the config in future:
		
		remoteConfigManagerReloadObserverToken = Current.remoteConfigManager.observatoryForReloads.append { [weak self] result in

			guard let self else { return }

			switch result {
				case .failure(let error):
					
					let configValidity = RemoteFileValidity.evaluateIfUpdateNeeded(
						configuration: Current.remoteConfigManager.storedConfiguration,
						lastFetchedTimestamp: Current.userSettings.configFetchedTimestamp,
						isAppLaunching: true,
						now: Current.now
					)
					
					switch configValidity {
						case .neverFetched, .refreshNeeded:
							self.delegate?.errorWhileLoading([(error: error, step: ErrorCode.Step.configuration)])
						case .withinTTL, .withinMinimalInterval:
							// We are within the TTL. Nothing to do.
							break
					}
				case .success(let (_, _, urlResponse, _)):
					// Mark remote config loaded
					Current.cryptoLibUtility.checkFile(.remoteConfiguration)
					
					// Update the server Date handlers
					self.updateServerDate(urlResponse)
					
					// Recheck the config
					self.checkRemoteConfiguration(Current.remoteConfigManager.storedConfiguration) {
						self.startApplication()
					}
			}
		}
	}
	
	// Update the  managers with the values from the actual http response
	/// - Parameter urlResponse: the url response from the config call
	private func updateServerDate(_ urlResponse: URLResponse) {
		
		// Fish for the server Date in the network response, and use that to maintain
		// a clockDeviationManager to check if the delta between the serverTime and the localTime is
		// beyond a permitted time interval.
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
