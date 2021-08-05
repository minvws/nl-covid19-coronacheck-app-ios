/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class HolderDashboardDatasourceSpy: HolderDashboardDatasourceProtocol {

	var invokedDidUpdateSetter = false
	var invokedDidUpdateSetterCount = 0
	var invokedDidUpdate: (([HolderDashboardViewModel.MyQRCard], [ExpiredQR]) -> Void)?
	var invokedDidUpdateList = [(([HolderDashboardViewModel.MyQRCard], [ExpiredQR]) -> Void)?]()
	var invokedDidUpdateGetter = false
	var invokedDidUpdateGetterCount = 0
	var stubbedDidUpdate: (([HolderDashboardViewModel.MyQRCard], [ExpiredQR]) -> Void)!

	var didUpdate: (([HolderDashboardViewModel.MyQRCard], [ExpiredQR]) -> Void)? {
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

	var invokedReload = false
	var invokedReloadCount = 0

	func reload() {
		invokedReload = true
		invokedReloadCount += 1
	}
}
