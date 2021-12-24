/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol FeatureFlagManaging {
	
	init(versionSupplier: AppVersionSupplierProtocol?)
	
	func isNewValidityInfoBannerEnabled() -> Bool
	
	func isVerificationPolicyEnabled() -> Bool
	
	func isVisitorPassEnabled() -> Bool
}

class FeatureFlagManager: FeatureFlagManaging, Logging {
	
	weak var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager
	private var versionSupplier: AppVersionSupplierProtocol?
	
	required init(versionSupplier: AppVersionSupplierProtocol?) {
		
		self.versionSupplier = versionSupplier
	}
	
	func isNewValidityInfoBannerEnabled() -> Bool {
		
		return remoteConfigManager?.storedConfiguration.showNewValidityInfoCard ?? false
	}
	
	func isVerificationPolicyEnabled() -> Bool {
		
		guard let versionSupplier = versionSupplier,
			  let configuration = remoteConfigManager?.storedConfiguration,
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
		
		return true

//		return remoteConfigManager?.storedConfiguration.visitorPassEnabled ?? false
	}
}
