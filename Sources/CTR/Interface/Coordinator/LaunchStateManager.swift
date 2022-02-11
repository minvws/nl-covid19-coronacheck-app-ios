/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol LaunchStateManaging {
	
	func handleLaunchState(_ state: LaunchState)
	
	func enableRestart()
	
	var versionSupplier: AppVersionSupplierProtocol { get set }
		
	var delegate: LaunchStateManagerDelegate? { get set }
}

protocol LaunchStateManagerDelegate: AnyObject {
	
	func appIsDeactivated()

	func applicationShouldStart()

	func cryptoLibDidNotInitialize()
		
	func errorWhileLoading(errors: [ServerError])
		
	func updateIsRequired(appStoreUrl: URL)
	
	func updateIsRecommended(version: String, appStoreUrl: URL)
}

final class LaunchStateManager: LaunchStateManaging, Logging {
	
	private var remoteConfigManagerObserverTokens = [RemoteConfigManager.ObserverToken]()
	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()
	private var applicationHasStarted = false
	weak var delegate: LaunchStateManagerDelegate?
	
	/// Initiializer
	init() {
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverTokens.forEach {
			Current.remoteConfigManager.removeObserver(token: $0)
		}
	}
	
	// MARK: - Launch State -
	
	func handleLaunchState(_ state: LaunchState) {
		
		if CommandLine.arguments.contains("-skipOnboarding") {
			self.startApplication()
			return
		}
		
		guard Current.cryptoLibUtility.isInitialized else {
			delegate?.cryptoLibDidNotInitialize()
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
					self.startApplication()
				case .serverError(let serviceErrors):
					if !self.applicationHasStarted {
						self.delegate?.errorWhileLoading(errors: serviceErrors)
					}
			}
		}
	}
	
	private func startApplication() {
		
		if !self.applicationHasStarted {
			self.applicationHasStarted = true
			// Only start once (we will get called multiple times (withinTTL, finished)
			self.delegate?.applicationShouldStart()
		}
	}
	
	private func checkRemoteConfiguration(_ remoteConfiguration: RemoteConfiguration, onContinue: (() -> Void)?) {
	
		let requiredVersion = remoteConfiguration.minimumVersion.fullVersionString()
		let recommendedVersion = remoteConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier.getCurrentVersion().fullVersionString()

		if remoteConfiguration.isDeactivated {
			
			self.delegate?.appIsDeactivated()
		} else if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending,
			let url = remoteConfiguration.appStoreURL {
			
			self.delegate?.updateIsRequired(appStoreUrl: url)
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
		
		if AppFlavor.flavor == .verifier {
			remoteConfigManagerObserverTokens += [Current.remoteConfigManager.appendUpdateObserver(updateVerificationPolicies)]
		}
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
	
	// MARK: - Verifier Verification Policy
	
	private func updateVerificationPolicies(for remoteConfiguration: RemoteConfiguration, data: Data, urlResponse: URLResponse) {
		guard let policies = remoteConfiguration.verificationPolicies else {
			// No feature flag available, enable default policy
			Current.verificationPolicyEnabler.enable(verificationPolicies: [])
			return
		}
		Current.verificationPolicyEnabler.enable(verificationPolicies: policies)
	}
}
