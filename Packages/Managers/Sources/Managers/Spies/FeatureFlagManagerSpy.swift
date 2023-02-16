/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

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

	var invokedIsVisitorPassEnabled = false
	var invokedIsVisitorPassEnabledCount = 0
	var stubbedIsVisitorPassEnabledResult: Bool! = false

	func isVisitorPassEnabled() -> Bool {
		invokedIsVisitorPassEnabled = true
		invokedIsVisitorPassEnabledCount += 1
		return stubbedIsVisitorPassEnabledResult
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

	var invokedAreZeroDisclosurePoliciesEnabled = false
	var invokedAreZeroDisclosurePoliciesEnabledCount = 0
	var stubbedAreZeroDisclosurePoliciesEnabledResult: Bool! = false

	func areZeroDisclosurePoliciesEnabled() -> Bool {
		invokedAreZeroDisclosurePoliciesEnabled = true
		invokedAreZeroDisclosurePoliciesEnabledCount += 1
		return stubbedAreZeroDisclosurePoliciesEnabledResult
	}

	var invokedIs1GExclusiveDisclosurePolicyEnabled = false
	var invokedIs1GExclusiveDisclosurePolicyEnabledCount = 0
	var stubbedIs1GExclusiveDisclosurePolicyEnabledResult: Bool! = false

	func is1GExclusiveDisclosurePolicyEnabled() -> Bool {
		invokedIs1GExclusiveDisclosurePolicyEnabled = true
		invokedIs1GExclusiveDisclosurePolicyEnabledCount += 1
		return stubbedIs1GExclusiveDisclosurePolicyEnabledResult
	}

	var invokedIs3GExclusiveDisclosurePolicyEnabled = false
	var invokedIs3GExclusiveDisclosurePolicyEnabledCount = 0
	var stubbedIs3GExclusiveDisclosurePolicyEnabledResult: Bool! = false

	func is3GExclusiveDisclosurePolicyEnabled() -> Bool {
		invokedIs3GExclusiveDisclosurePolicyEnabled = true
		invokedIs3GExclusiveDisclosurePolicyEnabledCount += 1
		return stubbedIs3GExclusiveDisclosurePolicyEnabledResult
	}

	var invokedAreBothDisclosurePoliciesEnabled = false
	var invokedAreBothDisclosurePoliciesEnabledCount = 0
	var stubbedAreBothDisclosurePoliciesEnabledResult: Bool! = false

	func areBothDisclosurePoliciesEnabled() -> Bool {
		invokedAreBothDisclosurePoliciesEnabled = true
		invokedAreBothDisclosurePoliciesEnabledCount += 1
		return stubbedAreBothDisclosurePoliciesEnabledResult
	}

	var invokedIsGGDPortalEnabled = false
	var invokedIsGGDPortalEnabledCount = 0
	var stubbedIsGGDPortalEnabledResult: Bool! = false

	func isGGDPortalEnabled() -> Bool {
		invokedIsGGDPortalEnabled = true
		invokedIsGGDPortalEnabledCount += 1
		return stubbedIsGGDPortalEnabledResult
	}
}
