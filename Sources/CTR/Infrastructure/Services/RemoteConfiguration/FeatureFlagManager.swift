/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol FeatureFlagManaging {
	
	func isNewValidityInfoBannerEnabled() -> Bool
	func isVerificationPolicyEnabled() -> Bool
	
	func isVisitorPassEnabled() -> Bool
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
	
	func isNewValidityInfoBannerEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.showNewValidityInfoCard ?? false
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
	
	func isVisitorPassEnabled() -> Bool {
		
		return remoteConfigManager.storedConfiguration.visitorPassEnabled ?? false
	}
}
