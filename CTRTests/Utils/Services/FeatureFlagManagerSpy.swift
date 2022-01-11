/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class FeatureFlagManagerSpy: FeatureFlagManaging {

	var invokedIsGGDEnabled = false
	var invokedIsGGDEnabledCount = 0
	var stubbedIsGGDEnabledResult: Bool! = false

	func isGGDEnabled() -> Bool {
		invokedIsGGDEnabled = true
		invokedIsGGDEnabledCount += 1
		return stubbedIsGGDEnabledResult
	}

	var invokedIsLuhnCheckEnabled = false
	var invokedIsLuhnCheckEnabledCount = 0
	var stubbedIsLuhnCheckEnabledResult: Bool! = false

	func isLuhnCheckEnabled() -> Bool {
		invokedIsLuhnCheckEnabled = true
		invokedIsLuhnCheckEnabledCount += 1
		return stubbedIsLuhnCheckEnabledResult
	}

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

	var invokedIsVisitorPassEnabled = false
	var invokedIsVisitorPassEnabledCount = 0
	var stubbedIsVisitorPassEnabledResult: Bool! = false

	func isVisitorPassEnabled() -> Bool {
		invokedIsVisitorPassEnabled = true
		invokedIsVisitorPassEnabledCount += 1
		return stubbedIsVisitorPassEnabledResult
	}
}
