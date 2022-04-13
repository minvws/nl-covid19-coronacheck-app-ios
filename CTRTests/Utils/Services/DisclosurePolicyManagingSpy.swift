/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class DisclosurePolicyManagingSpy: DisclosurePolicyManaging {

	var invokedFactoryGetter = false
	var invokedFactoryGetterCount = 0
	var stubbedFactory: NewDisclosurePolicyFactory!

	var factory: NewDisclosurePolicyFactory {
		invokedFactoryGetter = true
		invokedFactoryGetterCount += 1
		return stubbedFactory
	}

	var invokedObservatoryGetter = false
	var invokedObservatoryGetterCount = 0
	var stubbedObservatory: Observatory<Void>!

	var observatory: Observatory<Void> {
		invokedObservatoryGetter = true
		invokedObservatoryGetterCount += 1
		return stubbedObservatory
	}

	var invokedHasChangesGetter = false
	var invokedHasChangesGetterCount = 0
	var stubbedHasChanges: Bool! = false

	var hasChanges: Bool {
		invokedHasChangesGetter = true
		invokedHasChangesGetterCount += 1
		return stubbedHasChanges
	}

	var invokedSetDisclosurePolicyUpdateHasBeenSeen = false
	var invokedSetDisclosurePolicyUpdateHasBeenSeenCount = 0

	func setDisclosurePolicyUpdateHasBeenSeen() {
		invokedSetDisclosurePolicyUpdateHasBeenSeen = true
		invokedSetDisclosurePolicyUpdateHasBeenSeenCount += 1
	}

	var invokedGetDisclosurePolicies = false
	var invokedGetDisclosurePoliciesCount = 0
	var stubbedGetDisclosurePoliciesResult: [String]! = []

	func getDisclosurePolicies() -> [String] {
		invokedGetDisclosurePolicies = true
		invokedGetDisclosurePoliciesCount += 1
		return stubbedGetDisclosurePoliciesResult
	}
}
