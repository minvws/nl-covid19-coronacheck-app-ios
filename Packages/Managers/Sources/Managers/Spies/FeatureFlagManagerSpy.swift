/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public class FeatureFlagManagerSpy: FeatureFlagManaging {

	public var invokedIsGGDEnabled = false
	public var invokedIsGGDEnabledCount = 0
	public var stubbedIsGGDEnabledResult: Bool! = false

	public func isGGDEnabled() -> Bool {
		invokedIsGGDEnabled = true
		invokedIsGGDEnabledCount += 1
		return stubbedIsGGDEnabledResult
	}

	public var invokedIsLuhnCheckEnabled = false
	public var invokedIsLuhnCheckEnabledCount = 0
	public var stubbedIsLuhnCheckEnabledResult: Bool! = false

	public func isLuhnCheckEnabled() -> Bool {
		invokedIsLuhnCheckEnabled = true
		invokedIsLuhnCheckEnabledCount += 1
		return stubbedIsLuhnCheckEnabledResult
	}

	public var invokedAreMultipleVerificationPoliciesEnabled = false
	public var invokedAreMultipleVerificationPoliciesEnabledCount = 0
	public var stubbedAreMultipleVerificationPoliciesEnabledResult: Bool! = false

	public func areMultipleVerificationPoliciesEnabled() -> Bool {
		invokedAreMultipleVerificationPoliciesEnabled = true
		invokedAreMultipleVerificationPoliciesEnabledCount += 1
		return stubbedAreMultipleVerificationPoliciesEnabledResult
	}

	public var invokedIs1GVerificationPolicyEnabled = false
	public var invokedIs1GVerificationPolicyEnabledCount = 0
	public var stubbedIs1GVerificationPolicyEnabledResult: Bool! = false

	public func is1GVerificationPolicyEnabled() -> Bool {
		invokedIs1GVerificationPolicyEnabled = true
		invokedIs1GVerificationPolicyEnabledCount += 1
		return stubbedIs1GVerificationPolicyEnabledResult
	}

	public var invokedIsGGDPortalEnabled = false
	public var invokedIsGGDPortalEnabledCount = 0
	public var stubbedIsGGDPortalEnabledResult: Bool! = false

	public func isGGDPortalEnabled() -> Bool {
		invokedIsGGDPortalEnabled = true
		invokedIsGGDPortalEnabledCount += 1
		return stubbedIsGGDPortalEnabledResult
	}

	public var invokedIsMigrationEnabled = false
	public var invokedIsMigrationEnabledCount = 0
	public var stubbedIsMigrationEnabledResult: Bool! = false

	public func isMigrationEnabled() -> Bool {
		invokedIsMigrationEnabled = true
		invokedIsMigrationEnabledCount += 1
		return stubbedIsMigrationEnabledResult
	}

	public var invokedIsAddingEventsEnabled = false
	public var invokedIsAddingEventsEnabledCount = 0
	public var stubbedIsAddingEventsEnabledResult: Bool! = false

	public func isAddingEventsEnabled() -> Bool {
		invokedIsAddingEventsEnabled = true
		invokedIsAddingEventsEnabledCount += 1
		return stubbedIsAddingEventsEnabledResult
	}

	public var invokedIsScanningEventsEnabled = false
	public var invokedIsScanningEventsEnabledCount = 0
	public var stubbedIsScanningEventsEnabledResult: Bool! = false

	public func isScanningEventsEnabled() -> Bool {
		invokedIsScanningEventsEnabled = true
		invokedIsScanningEventsEnabledCount += 1
		return stubbedIsScanningEventsEnabledResult
	}
}
