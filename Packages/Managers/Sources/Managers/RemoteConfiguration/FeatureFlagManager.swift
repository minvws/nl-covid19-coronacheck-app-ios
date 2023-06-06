/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Models

public protocol FeatureFlagManaging {
	
	///  Can we use the GGD for negative tests?
	/// - Returns: True if we can
	func isGGDEnabled() -> Bool
	
	///  Should we use the luhn check for tokens?
	/// - Returns: True if we can
	func isLuhnCheckEnabled() -> Bool
	
	// Verifier
	func areMultipleVerificationPoliciesEnabled() -> Bool
	func is1GVerificationPolicyEnabled() -> Bool
	
	// Holder
	func isGGDPortalEnabled() -> Bool
	func isMigrationEnabled() -> Bool
	func isAddingEventsEnabled() -> Bool
	func isScanningEventsEnabled() -> Bool
}

public class FeatureFlagManager: FeatureFlagManaging {
	
	private var remoteConfigManager: RemoteConfigManaging
	private var userSettings: UserSettingsProtocol
	
	public required init(
		remoteConfigManager: RemoteConfigManaging,
		userSettings: UserSettingsProtocol
	) {
		
		self.remoteConfigManager = remoteConfigManager
		self.userSettings = userSettings
	}
	
	///  Can we use the GGD for negative tests?
	/// - Returns: True if we can
	public func isGGDEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.isGGDEnabled ?? false
	}
	
	public func isGGDPortalEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.isPAPEnabled ?? false
	}
	
	///  Should we use the luhn check for tokens?
	/// - Returns: True if we can
	public func isLuhnCheckEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.isLuhnCheckEnabled ?? false
	}
	
	public func areMultipleVerificationPoliciesEnabled() -> Bool {
		
		guard let verificationPolicies = remoteConfigManager.storedConfiguration.verificationPolicies else {
			return false
		}
		return verificationPolicies.contains(VerificationPolicy.policy3G.featureFlag) &&
		verificationPolicies.contains(VerificationPolicy.policy1G.featureFlag)
	}
	
	public func is1GVerificationPolicyEnabled() -> Bool { // Verifier
		
		guard let verificationPolicies = remoteConfigManager.storedConfiguration.verificationPolicies else {
			return false
		}
		return verificationPolicies.contains(VerificationPolicy.policy1G.featureFlag)
	}
	
	// Holder
	
	public func isMigrationEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.migrateButtonEnabled ?? true
	}
	
	public func isAddingEventsEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.addEventsButtonEnabled ?? true
	}
	
	public func isScanningEventsEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.scanCertificateButtonEnabled ?? true
	}
}
