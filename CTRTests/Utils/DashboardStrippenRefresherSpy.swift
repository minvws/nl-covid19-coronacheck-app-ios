/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class DashboardStrippenRefresherSpy: DashboardStrippenRefreshing {

	var invokedDidUpdateSetter = false
	var invokedDidUpdateSetterCount = 0
	var invokedDidUpdate: ((DashboardStrippenRefresher.State?, DashboardStrippenRefresher.State) -> Void)?
	var invokedDidUpdateList = [((DashboardStrippenRefresher.State?, DashboardStrippenRefresher.State) -> Void)?]()
	var invokedDidUpdateGetter = false
	var invokedDidUpdateGetterCount = 0
	var stubbedDidUpdate: ((DashboardStrippenRefresher.State?, DashboardStrippenRefresher.State) -> Void)!

	var didUpdate: ((DashboardStrippenRefresher.State?, DashboardStrippenRefresher.State) -> Void)? {
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

	var invokedLoad = false
	var invokedLoadCount = 0

	func load() {
		invokedLoad = true
		invokedLoadCount += 1
	}

	var invokedUserDismissedALoadingError = false
	var invokedUserDismissedALoadingErrorCount = 0

	func userDismissedALoadingError() {
		invokedUserDismissedALoadingError = true
		invokedUserDismissedALoadingErrorCount += 1
	}
}
