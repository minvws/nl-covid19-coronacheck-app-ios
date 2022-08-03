/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability
@testable import CTR

class ReachabilitySpy: ReachabilityProtocol {

	var invokedWhenReachableSetter = false
	var invokedWhenReachableSetterCount = 0
	var invokedWhenReachable: ((Reachability) -> Void)?
	var invokedWhenReachableList = [((Reachability) -> Void)?]()
	var invokedWhenReachableGetter = false
	var invokedWhenReachableGetterCount = 0
	var stubbedWhenReachable: ((Reachability) -> Void)!

	var whenReachable: ((Reachability) -> Void)? {
		set {
			invokedWhenReachableSetter = true
			invokedWhenReachableSetterCount += 1
			invokedWhenReachable = newValue
			invokedWhenReachableList.append(newValue)
		}
		get {
			invokedWhenReachableGetter = true
			invokedWhenReachableGetterCount += 1
			return stubbedWhenReachable
		}
	}

	var invokedStartNotifier = false
	var invokedStartNotifierCount = 0
	var stubbedStartNotifierError: Error?

	func startNotifier() throws {
		invokedStartNotifier = true
		invokedStartNotifierCount += 1
		if let error = stubbedStartNotifierError {
			throw error
		}
	}
}
