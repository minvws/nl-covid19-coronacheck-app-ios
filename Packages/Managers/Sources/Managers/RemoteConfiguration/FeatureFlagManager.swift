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
	func isVisitorPassEnabled() -> Bool
	
	// Verifier
	func areMultipleVerificationPoliciesEnabled() -> Bool
	func is1GVerificationPolicyEnabled() -> Bool
	
	// Holder
	func areZeroDisclosurePoliciesEnabled() -> Bool
	func isGGDPortalEnabled() -> Bool
}

public class FeatureFlagManager: FeatureFlagManaging {
	
	private var remoteConfigManager: RemoteConfigManaging
	private var disclosurePolicyManager: DisclosurePolicyManaging
	private var userSettings: UserSettingsProtocol
	
	public required init(
		remoteConfigManager: RemoteConfigManaging,
		disclosurePolicyManager: DisclosurePolicyManaging,
		userSettings: UserSettingsProtocol
	) {
		
		self.remoteConfigManager = remoteConfigManager
		self.disclosurePolicyManager = disclosurePolicyManager
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
	
	public func isVisitorPassEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.visitorPassEnabled ?? false
	}
	
	public func areMultipleVerificationPoliciesEnabled() -> Bool {
		
		guard let verificationPolicies = remoteConfigManager.storedConfiguration.verificationPolicies else {
			return false
		}
		return verificationPolicies.contains(VerificationPolicy.policy3G.featureFlag) &&
		verificationPolicies.contains(VerificationPolicy.policy1G.featureFlag)
	}
	
	public func is1GVerificationPolicyEnabled() -> Bool {
		
		guard let verificationPolicies = remoteConfigManager.storedConfiguration.verificationPolicies else {
			return false
		}
		return verificationPolicies.contains(VerificationPolicy.policy1G.featureFlag)
	}
	
	// Holder
	
	public func areZeroDisclosurePoliciesEnabled() -> Bool {
		return true
	}
}
