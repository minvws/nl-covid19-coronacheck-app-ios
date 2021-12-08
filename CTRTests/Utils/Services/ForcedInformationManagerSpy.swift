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

	var invokedFactorySetter = false
	var invokedFactorySetterCount = 0
	var invokedFactory: ForcedInformationFactory?
	var invokedFactoryList = [ForcedInformationFactory?]()
	var invokedFactoryGetter = false
	var invokedFactoryGetterCount = 0
	var stubbedFactory: ForcedInformationFactory!

	var factory: ForcedInformationFactory? {
		set {
			invokedFactorySetter = true
			invokedFactorySetterCount += 1
			invokedFactory = newValue
			invokedFactoryList.append(newValue)
		}
		get {
			invokedFactoryGetter = true
			invokedFactoryGetterCount += 1
			return stubbedFactory
		}
	}

	var invokedNeedsUpdatingGetter = false
	var invokedNeedsUpdatingGetterCount = 0
	var stubbedNeedsUpdating: Bool! = false

	var needsUpdating: Bool {
		invokedNeedsUpdatingGetter = true
		invokedNeedsUpdatingGetterCount += 1
		return stubbedNeedsUpdating
	}

	var invokedGetUpdatePage = false
	var invokedGetUpdatePageCount = 0
	var stubbedGetUpdatePageResult: ForcedInformationPage!

	func getUpdatePage() -> ForcedInformationPage? {
		invokedGetUpdatePage = true
		invokedGetUpdatePageCount += 1
		return stubbedGetUpdatePageResult
	}

	var invokedGetConsent = false
	var invokedGetConsentCount = 0
	var stubbedGetConsentResult: ForcedInformationConsent!

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

	var invokedReset = false
	var invokedResetCount = 0

	func reset() {
		invokedReset = true
		invokedResetCount += 1
	}
}
