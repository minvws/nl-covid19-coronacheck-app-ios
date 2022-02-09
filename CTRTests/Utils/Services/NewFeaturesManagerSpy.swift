/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class NewFeaturesManagerSpy: NewFeaturesManaging {

	var invokedFactorySetter = false
	var invokedFactorySetterCount = 0
	var invokedFactory: NewFeaturesFactory?
	var invokedFactoryList = [NewFeaturesFactory?]()
	var invokedFactoryGetter = false
	var invokedFactoryGetterCount = 0
	var stubbedFactory: NewFeaturesFactory!

	var factory: NewFeaturesFactory? {
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
	var stubbedGetUpdatePageResult: NewFeatureItem!

	func getNewFeatureItem() -> NewFeatureItem? {
		invokedGetUpdatePage = true
		invokedGetUpdatePageCount += 1
		return stubbedGetUpdatePageResult
	}

	var invokedGetConsent = false
	var invokedGetConsentCount = 0
	var stubbedGetConsentResult: NewFeatureConsent!

	func getConsent() -> NewFeatureConsent? {
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

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
