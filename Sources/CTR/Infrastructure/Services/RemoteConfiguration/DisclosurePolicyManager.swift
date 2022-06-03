/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol DisclosurePolicyManaging {
	func setDisclosurePolicyUpdateHasBeenSeen()
	func getDisclosurePolicies() -> [String]
	
	var factory: UpdatedDisclosurePolicyFactory { get }
	var observatory: Observatory<Void> { get }
	var hasChanges: Bool { get }
}

class DisclosurePolicyManager: DisclosurePolicyManaging {
	
	let factory: UpdatedDisclosurePolicyFactory = UpdatedDisclosurePolicyFactory()
	
	// Mechanism for registering for external state change notifications:
	let observatory: Observatory<Void>
	private let notifyObservers: (()) -> Void
	
	private var remoteConfigManagerObserverToken: Observatory.ObserverToken?
	private var remoteConfigManager: RemoteConfigManaging
	private let logHandler: Logging?
	private let userSettings: UserSettingsProtocol
	
	/// Initiializer
	init(remoteConfigManager: RemoteConfigManaging, userSettings: UserSettingsProtocol, logHandler: Logging? = nil) {
		self.remoteConfigManager = remoteConfigManager
		self.logHandler = logHandler
		self.userSettings = userSettings
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
		logHandler?.logDebug("DisclosurePolicyManager: policy changed detected")

		// - Update the observers
		notifyObservers(())
	}
	
	func setDisclosurePolicyUpdateHasBeenSeen() {
		
		let disclosurePolicies = getDisclosurePolicies()
		userSettings.lastKnownConfigDisclosurePolicy = disclosurePolicies
	}
	
	var hasChanges: Bool {
		
		let disclosurePolicies = getDisclosurePolicies()
		return userSettings.lastKnownConfigDisclosurePolicy != disclosurePolicies
	}
	
	func getDisclosurePolicies() -> [String] {
		
		guard var disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return []
		}
		
		if userSettings.overrideDisclosurePolicies.isNotEmpty {
			disclosurePolicies = userSettings.overrideDisclosurePolicies
		}
		return disclosurePolicies
	}
}
