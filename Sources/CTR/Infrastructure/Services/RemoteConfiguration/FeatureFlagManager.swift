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
	func areMultipleVerificationPoliciesEnabled() -> Bool
	func is1GVerificationPolicyEnabled() -> Bool
	
	// Holder
	func areZeroDisclosurePoliciesEnabled() -> Bool
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
	
	func areZeroDisclosurePoliciesEnabled() -> Bool {
		
		if CommandLine.arguments.contains("-disclosurePolicyMode0G") {
			return true
		} else if CommandLine.arguments.contains("-disclosurePolicyMode1G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode1GWith3G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode3G") {
			return false
		}
		
		guard let disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return true
		}
		
		return disclosurePolicies.isEmpty || Current.userSettings.overrideDisclosurePolicies == ["0G"]
	}
	
	func is3GExclusiveDisclosurePolicyEnabled() -> Bool {
		
		if CommandLine.arguments.contains("-disclosurePolicyMode3G") {
			return true
		} else if CommandLine.arguments.contains("-disclosurePolicyMode1G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode1GWith3G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode0G") {
			return false
		}
		
		guard var disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return false
		}
		
		if Current.userSettings.overrideDisclosurePolicies.isNotEmpty {
			disclosurePolicies = Current.userSettings.overrideDisclosurePolicies
		}
		
		return disclosurePolicies == [DisclosurePolicy.policy3G.featureFlag]
	}
	
	func is1GExclusiveDisclosurePolicyEnabled() -> Bool {
		
		if CommandLine.arguments.contains("-disclosurePolicyMode1G") {
			return true
		} else if CommandLine.arguments.contains("-disclosurePolicyMode3G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode1GWith3G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode0G") {
			return false
		}
		
		guard var disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return false
		}
		
		if Current.userSettings.overrideDisclosurePolicies.isNotEmpty {
			disclosurePolicies = Current.userSettings.overrideDisclosurePolicies
		}
		
		return disclosurePolicies == [DisclosurePolicy.policy1G.featureFlag]
	}
	
	func areBothDisclosurePoliciesEnabled() -> Bool {
		
		if CommandLine.arguments.contains("-disclosurePolicyMode1GWith3G") {
			return true
		} else if CommandLine.arguments.contains("-disclosurePolicyMode1G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode3G") ||
			CommandLine.arguments.contains("-disclosurePolicyMode0G") {
			return false
		}
		
		guard var disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return false
		}
		
		if Current.userSettings.overrideDisclosurePolicies.isNotEmpty {
			disclosurePolicies = Current.userSettings.overrideDisclosurePolicies
		}
		
		return disclosurePolicies.contains(DisclosurePolicy.policy3G.featureFlag) &&
		disclosurePolicies.contains(DisclosurePolicy.policy1G.featureFlag)
	}
}
