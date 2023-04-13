/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

// MARK: - Test Doubles

class OnboardingCoordinatorSpy: OnboardingCoordinatorDelegate, OpenUrlProtocol {

	var invokedConsentGiven = false
	var invokedConsentGivenCount = 0

	func consentGiven() {
		invokedConsentGiven = true
		invokedConsentGivenCount += 1
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()

	func openUrl(_ url: URL) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
	}
}
