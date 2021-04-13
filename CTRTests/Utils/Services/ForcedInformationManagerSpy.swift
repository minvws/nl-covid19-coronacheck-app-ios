/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ForcedInformationManagerSpy: ForcedInformationManaging {

	required init() {}

	var invokedNeedsUpdatingGetter = false
	var invokedNeedsUpdatingGetterCount = 0
	var stubbedNeedsUpdating: Bool! = false

	var needsUpdating: Bool {
		invokedNeedsUpdatingGetter = true
		invokedNeedsUpdatingGetterCount += 1
		return stubbedNeedsUpdating
	}

	var invokedGetConsent = false
	var invokedGetConsentCount = 0
	var stubbedGetConsentResult: ForcedInformationConsent?

	func getConsent() -> ForcedInformationConsent? {
		invokedGetConsent = true
		invokedGetConsentCount += 1
		return stubbedGetConsentResult
	}

	var invokedConsentGiven = false
	var invokedConsentGivenCount = 0

	func consentGiven() {
		invokedConsentGiven = true
		invokedConsentGivenCount += 1
	}
}
