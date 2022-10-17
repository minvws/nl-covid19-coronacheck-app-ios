/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

// swiftlint:disable:next type_name
class HolderDashboardRemovedEventsDatasourceSpy: HolderDashboardRemovedEventsDatasourceProtocol {

	var invokedDidUpdateSetter = false
	var invokedDidUpdateSetterCount = 0
	var invokedDidUpdate: (([RemovedEventItem]) -> Void)?
	var invokedDidUpdateList = [(([RemovedEventItem]) -> Void)?]()
	var invokedDidUpdateGetter = false
	var invokedDidUpdateGetterCount = 0
	var stubbedDidUpdate: (([RemovedEventItem]) -> Void)!

	var didUpdate: (([RemovedEventItem]) -> Void)? {
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
