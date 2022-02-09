/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol FeatureFlagManaging {
	
	///  Can we use the GGD for negative tests?
	/// - Returns: True if we can
	func isGGDEnabled() -> Bool
	
	///  Should we use the luhn check for tokens?
	/// - Returns: True if we can
	func isLuhnCheckEnabled() -> Bool
	func isNewValidityInfoBannerEnabled() -> Bool
	func isVisitorPassEnabled() -> Bool
	
	// Verifier
	func isVerificationPolicyEnabled() -> Bool
	func areMultipleVerificationPoliciesEnabled() -> Bool
	func is1GVerificationPolicyEnabled() -> Bool
	
	// Holder
	func is1GExclusiveDisclosurePolicyEnabled() -> Bool
	func is3GExclusiveDisclosurePolicyEnabled() -> Bool
	func areBothDisclosurePoliciesEnabled() -> Bool
}

class FeatureFlagManager: FeatureFlagManaging, Logging {
	
	private var remoteConfigManager: RemoteConfigManaging
	private var versionSupplier: AppVersionSupplierProtocol?
	
	required init(
		versionSupplier: AppVersionSupplierProtocol?,
		remoteConfigManager: RemoteConfigManaging
	) {
		
		self.versionSupplier = versionSupplier
		self.remoteConfigManager = remoteConfigManager
	}
	
	///  Can we use the GGD for negative tests?
	/// - Returns: True if we can
	func isGGDEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.isGGDEnabled ?? false
	}
	
	///  Should we use the luhn check for tokens?
	/// - Returns: True if we can
	func isLuhnCheckEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.isLuhnCheckEnabled ?? false
	}
	
	func isNewValidityInfoBannerEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.showNewValidityInfoCard ?? false
	}
	
	func isVisitorPassEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.visitorPassEnabled ?? false
	}
	
	func isVerificationPolicyEnabled() -> Bool {
		
		let configuration = remoteConfigManager.storedConfiguration
		
		guard let versionSupplier = versionSupplier,
			  let verificationPolicyVersion = configuration.verificationPolicyVersion else { return false }
		
		guard verificationPolicyVersion != "0" else {
			// "0" means verification Policy is disabled
			return false
		}
		
		let requiredVersion = verificationPolicyVersion.fullVersionString()
		let currentVersion = versionSupplier.getCurrentVersion().fullVersionString()
		
		guard requiredVersion.compare(currentVersion, options: .numeric) != .orderedDescending else {
			// Current version is lower than the required version -> Disabled
			return false
		}
		
		// Current version is higher or equal to the required version -> Enabled
		return true
	}
	
	func areMultipleVerificationPoliciesEnabled() -> Bool {
		
		guard let verificationPolicies = remoteConfigManager.storedConfiguration.verificationPolicies else {
			return false
		}
		return verificationPolicies.contains(VerificationPolicy.policy3G.featureFlag) &&
		verificationPolicies.contains(VerificationPolicy.policy1G.featureFlag)
	}
	
	func is1GVerificationPolicyEnabled() -> Bool {
		
		guard let verificationPolicies = remoteConfigManager.storedConfiguration.verificationPolicies else {
			return false
		}
		return verificationPolicies.contains(VerificationPolicy.policy1G.featureFlag)
	}
	
	// Holder
	func is3GExclusiveDisclosurePolicyEnabled() -> Bool {
		
		guard let disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return false
		}
		return (disclosurePolicies.contains(DisclosurePolicy.policy3G.featureFlag)
		&& !disclosurePolicies.contains(DisclosurePolicy.policy1G.featureFlag)) ||
		disclosurePolicies.isEmpty
	}
	
	func is1GExclusiveDisclosurePolicyEnabled() -> Bool {
		
		guard let disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return false
		}
		return disclosurePolicies.contains(DisclosurePolicy.policy1G.featureFlag)
		&& !disclosurePolicies.contains(DisclosurePolicy.policy3G.featureFlag)
	}
	
	func areBothDisclosurePoliciesEnabled() -> Bool {
		
		guard let disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return false
		}
		
		return disclosurePolicies.contains(DisclosurePolicy.policy3G.featureFlag) &&
		disclosurePolicies.contains(DisclosurePolicy.policy1G.featureFlag)
	}
}
