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

extension FeatureFlagManagerSpy {
    
    convenience init() {
        self.init(versionSupplier: AppVersionSupplier())
    }
}
