/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import Foundation

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
}
