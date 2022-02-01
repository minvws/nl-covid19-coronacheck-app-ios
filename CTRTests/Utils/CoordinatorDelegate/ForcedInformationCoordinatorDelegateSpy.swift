/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class NewFeaturesCoordinatorDelegateSpy: NewFeaturesCoordinatorDelegate, OpenUrlProtocol {

	var invokedDidFinish = false
	var invokedDidFinishCount = 0
	var invokedDidFinishParameters: (result: NewFeaturesScreenResult, Void)?
	var invokedDidFinishParametersList = [(result: NewFeaturesScreenResult, Void)]()

	func didFinish(_ result: NewFeaturesScreenResult) {
		invokedDidFinish = true
		invokedDidFinishCount += 1
		invokedDidFinishParameters = (result, ())
		invokedDidFinishParametersList.append((result, ()))
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, inApp: Bool)?
	var invokedOpenUrlParametersList = [(url: URL, inApp: Bool)]()

	func openUrl(_ url: URL, inApp: Bool) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, inApp)
		invokedOpenUrlParametersList.append((url, inApp))
	}
}
