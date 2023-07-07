/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability

public class ReachabilitySpy: ReachabilityProtocol {
	
	public init() {}

	public var invokedWhenReachableSetter = false
	public var invokedWhenReachableSetterCount = 0
	public var invokedWhenReachable: ((Reachability) -> Void)?
	public var invokedWhenReachableList = [((Reachability) -> Void)?]()
	public var invokedWhenReachableGetter = false
	public var invokedWhenReachableGetterCount = 0
	public var stubbedWhenReachable: ((Reachability) -> Void)!

	public var whenReachable: ((Reachability) -> Void)? {
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

	public var invokedWhenUnreachableSetter = false
	public var invokedWhenUnreachableSetterCount = 0
	public var invokedWhenUnreachable: ((Reachability) -> Void)?
	public var invokedWhenUnreachableList = [((Reachability) -> Void)?]()
	public var invokedWhenUnreachableGetter = false
	public var invokedWhenUnreachableGetterCount = 0
	public var stubbedWhenUnreachable: ((Reachability) -> Void)!

	public var whenUnreachable: ((Reachability) -> Void)? {
		set {
			invokedWhenUnreachableSetter = true
			invokedWhenUnreachableSetterCount += 1
			invokedWhenUnreachable = newValue
			invokedWhenUnreachableList.append(newValue)
		}
		get {
			invokedWhenUnreachableGetter = true
			invokedWhenUnreachableGetterCount += 1
			return stubbedWhenUnreachable
		}
	}

	public var invokedStartNotifier = false
	public var invokedStartNotifierCount = 0
	public var stubbedStartNotifierError: Error?

	public func startNotifier() throws {
		invokedStartNotifier = true
		invokedStartNotifierCount += 1
		if let error = stubbedStartNotifierError {
			throw error
		}
	}
}
