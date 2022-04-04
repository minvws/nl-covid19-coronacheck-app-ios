/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol DisclosurePolicyManaging {
	func setDisclosurePolicyUpdateHasBeenSeen()
	func getDisclosurePolicies() -> [String]
	
	var observatory: Observatory<Void> { get }
	var hasChanges: Bool { get }
}

class DisclosurePolicyManager: Logging, DisclosurePolicyManaging {
	// Mechanism for registering for external state change notifications:
	let observatory: Observatory<Void>
	private let notifyObservers: (Void) -> Void
	
	private var remoteConfigManagerObserverToken: Observatory.ObserverToken?
	private var remoteConfigManager: RemoteConfigManaging
	
	/// Initiializer
	init(remoteConfigManager: RemoteConfigManaging) {
		self.remoteConfigManager = remoteConfigManager
		(self.observatory, self.notifyObservers) = Observatory<()>.create()
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverToken.map(Current.remoteConfigManager.observatoryForUpdates.remove)
	}
	
	private func configureRemoteConfigManager() {
		
		remoteConfigManagerObserverToken = remoteConfigManager.observatoryForUpdates.append { [weak self] _, _, _ in
			self?.detectPolicyChange()
		}
	}
		
	func detectPolicyChange() {
		
		guard hasChanges else {
			return
		}
		
		// Locally stored profile different than the remote ones
		logDebug("DisclosurePolicyManager: policy changed detected")

		// - Update the observers
		notifyObservers(())
	}
	
	func setDisclosurePolicyUpdateHasBeenSeen() {
		
		let disclosurePolicies = getDisclosurePolicies()
		Current.userSettings.lastKnownConfigDisclosurePolicy = disclosurePolicies
	}
	
	var hasChanges: Bool {
		
		let disclosurePolicies = getDisclosurePolicies()
		return Current.userSettings.lastKnownConfigDisclosurePolicy != disclosurePolicies
	}
	
	func getDisclosurePolicies() -> [String] {
		
		guard var disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return []
		}
		
		if Current.userSettings.overrideDisclosurePolicies.isNotEmpty {
			disclosurePolicies = Current.userSettings.overrideDisclosurePolicies
		}
		return disclosurePolicies
	}
}
