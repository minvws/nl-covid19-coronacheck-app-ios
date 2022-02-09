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

	var invokedIsVisitorPassEnabled = false
	var invokedIsVisitorPassEnabledCount = 0
	var stubbedIsVisitorPassEnabledResult: Bool! = false

	func isVisitorPassEnabled() -> Bool {
		invokedIsVisitorPassEnabled = true
		invokedIsVisitorPassEnabledCount += 1
		return stubbedIsVisitorPassEnabledResult
	}

	var invokedIsVerificationPolicyEnabled = false
	var invokedIsVerificationPolicyEnabledCount = 0
	var stubbedIsVerificationPolicyEnabledResult: Bool! = false

	func isVerificationPolicyEnabled() -> Bool {
		invokedIsVerificationPolicyEnabled = true
		invokedIsVerificationPolicyEnabledCount += 1
		return stubbedIsVerificationPolicyEnabledResult
	}

	var invokedAreMultipleVerificationPoliciesEnabled = false
	var invokedAreMultipleVerificationPoliciesEnabledCount = 0
	var stubbedAreMultipleVerificationPoliciesEnabledResult: Bool! = false

	func areMultipleVerificationPoliciesEnabled() -> Bool {
		invokedAreMultipleVerificationPoliciesEnabled = true
		invokedAreMultipleVerificationPoliciesEnabledCount += 1
		return stubbedAreMultipleVerificationPoliciesEnabledResult
	}

	var invokedIs1GVerificationPolicyEnabled = false
	var invokedIs1GVerificationPolicyEnabledCount = 0
	var stubbedIs1GVerificationPolicyEnabledResult: Bool! = false

	func is1GVerificationPolicyEnabled() -> Bool {
		invokedIs1GVerificationPolicyEnabled = true
		invokedIs1GVerificationPolicyEnabledCount += 1
		return stubbedIs1GVerificationPolicyEnabledResult
	}

	var invokedAreMultipleDisclosurePoliciesEnabled = false
	var invokedAreMultipleDisclosurePoliciesEnabledCount = 0
	var stubbedAreMultipleDisclosurePoliciesEnabledResult: Bool! = false

	func areBothDisclosurePoliciesEnabled() -> Bool {
		invokedAreMultipleDisclosurePoliciesEnabled = true
		invokedAreMultipleDisclosurePoliciesEnabledCount += 1
		return stubbedAreMultipleDisclosurePoliciesEnabledResult
	}

	var invokedIs1GDisclosurePolicyEnabled = false
	var invokedIs1GDisclosurePolicyEnabledCount = 0
	var stubbedIs1GDisclosurePolicyEnabledResult: Bool! = false

	func is1GExclusiveDisclosurePolicyEnabled() -> Bool {
		invokedIs1GDisclosurePolicyEnabled = true
		invokedIs1GDisclosurePolicyEnabledCount += 1
		return stubbedIs1GDisclosurePolicyEnabledResult
	}

	var invokedIs3GDisclosurePolicyEnabled = false
	var invokedIs3GDisclosurePolicyEnabledCount = 0
	var stubbedIs3GDisclosurePolicyEnabledResult: Bool! = false

	func is3GExclusiveDisclosurePolicyEnabled() -> Bool {
		invokedIs3GDisclosurePolicyEnabled = true
		invokedIs3GDisclosurePolicyEnabledCount += 1
		return stubbedIs3GDisclosurePolicyEnabledResult
	}
}
