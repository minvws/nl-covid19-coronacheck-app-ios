/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

// swiftlint:disable:next type_name
class HolderDashboardBlockedEventsDatasourceSpy: HolderDashboardBlockedEventsDatasourceProtocol {

	var invokedDidUpdateSetter = false
	var invokedDidUpdateSetterCount = 0
	var invokedDidUpdate: (([BlockedEventItem]) -> Void)?
	var invokedDidUpdateList = [(([BlockedEventItem]) -> Void)?]()
	var invokedDidUpdateGetter = false
	var invokedDidUpdateGetterCount = 0
	var stubbedDidUpdate: (([BlockedEventItem]) -> Void)!

	var didUpdate: (([BlockedEventItem]) -> Void)? {
		set {
			invokedDidUpdateSetter = true
			invokedDidUpdateSetterCount += 1
			invokedDidUpdate = newValue
			invokedDidUpdateList.append(newValue)
		}
		get {
			invokedDidUpdateGetter = true
			invokedDidUpdateGetterCount += 1
			return stubbedDidUpdate
		}
	}
}
