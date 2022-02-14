/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol DisclosurePolicyManaging {
	
	typealias ObserverToken = UUID
	
	func appendPolicyChangedObserver(_ observer: @escaping () -> Void) -> ObserverToken
	func removeObserver(token: ObserverToken)
}

class DisclosurePolicyManager: Logging {
	
	private var remoteConfigManagerObserverToken: RemoteConfigManager.ObserverToken?
	private var remoteConfigManager: RemoteConfigManaging
	private var observers = [ObserverToken: () -> Void]()
	
	/// Initiializer
	init(remoteConfigManager: RemoteConfigManaging) {
		self.remoteConfigManager = remoteConfigManager
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverToken.map(Current.remoteConfigManager.removeObserver)
	}
	
	private func configureRemoteConfigManager() {
		
		remoteConfigManagerObserverToken = remoteConfigManager.appendUpdateObserver { [weak self] _, _, _ in
			self?.detectPolicyChange()
		}
	}
		
	func detectPolicyChange() {
				
		if Current.userSettings.lastKnownConfigDisclosurePolicy != Current.remoteConfigManager.storedConfiguration.disclosurePolicies {
			// Locally stored profile different than the remote ones
			logDebug("DisclosurePolicyManager: policy changed detected")
			// - Update the locally stored profile
			Current.userSettings.lastKnownConfigDisclosurePolicy = Current.remoteConfigManager.storedConfiguration.disclosurePolicies ?? []
			// - Update the observers
			notifyObservers()
		}
	}
}

// MARK: - DisclosurePolicyManaging

extension DisclosurePolicyManager: DisclosurePolicyManaging {
	
	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func appendPolicyChangedObserver(_ observer: @escaping () -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		observers[newToken] = observer
		return newToken
	}
	
	func removeObserver(token: ObserverToken) {
		observers[token] = nil
	}
	
	func notifyObservers() {
		observers.values.forEach { callback in
			callback()
		}
	}
}
