/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class AppCoordinatorSpy: AppCoordinatorDelegate {

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()
	var shouldInvokeOpenUrlCompletionHandler = false

	func openUrl(_ url: URL, completionHandler: (() -> Void)?) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
		if shouldInvokeOpenUrlCompletionHandler {
			completionHandler?()
		}
	}

	var invokedHandleLaunchState = false
	var invokedHandleLaunchStateCount = 0
	var invokedHandleLaunchStateParameters: (state: LaunchState, Void)?
	var invokedHandleLaunchStateParametersList = [(state: LaunchState, Void)]()

	func handleLaunchState(_ state: LaunchState) {
		invokedHandleLaunchState = true
		invokedHandleLaunchStateCount += 1
		invokedHandleLaunchStateParameters = (state, ())
		invokedHandleLaunchStateParametersList.append((state, ()))
	}

	var invokedRetry = false
	var invokedRetryCount = 0

	func retry() {
		invokedRetry = true
		invokedRetryCount += 1
	}
}
