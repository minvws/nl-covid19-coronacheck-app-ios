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

	var invokedIsGGDPortalEnabled = false
	var invokedIsGGDPortalEnabledCount = 0
	var stubbedIsGGDPortalEnabledResult: Bool! = false

	func isGGDPortalEnabled() -> Bool {
		invokedIsGGDPortalEnabled = true
		invokedIsGGDPortalEnabledCount += 1
		return stubbedIsGGDPortalEnabledResult
	}
}
