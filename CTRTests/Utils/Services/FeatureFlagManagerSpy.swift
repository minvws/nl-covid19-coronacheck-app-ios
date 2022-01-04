/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class FeatureFlagManagerSpy: FeatureFlagManaging {

	required init(versionSupplier: AppVersionSupplierProtocol?) {}

	var invokedIsNewValidityInfoBannerEnabled = false
	var invokedIsNewValidityInfoBannerEnabledCount = 0
	var stubbedIsNewValidityInfoBannerEnabledResult: Bool! = false

	func isNewValidityInfoBannerEnabled() -> Bool {
		invokedIsNewValidityInfoBannerEnabled = true
		invokedIsNewValidityInfoBannerEnabledCount += 1
		return stubbedIsNewValidityInfoBannerEnabledResult
	}

	var invokedIsVerificationPolicyEnabled = false
	var invokedIsVerificationPolicyEnabledCount = 0
	var stubbedIsVerificationPolicyEnabledResult: Bool! = false

	func isVerificationPolicyEnabled() -> Bool {
		invokedIsVerificationPolicyEnabled = true
		invokedIsVerificationPolicyEnabledCount += 1
		return stubbedIsVerificationPolicyEnabledResult
	}
}
