/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OnboardingManagerSpy: OnboardingManaging {

	var invokedNeedsOnboardingGetter = false
	var invokedNeedsOnboardingGetterCount = 0
	var stubbedNeedsOnboarding: Bool! = false

	var needsOnboarding: Bool {
		invokedNeedsOnboardingGetter = true
		invokedNeedsOnboardingGetterCount += 1
		return stubbedNeedsOnboarding
	}

	var invokedNeedsConsentGetter = false
	var invokedNeedsConsentGetterCount = 0
	var stubbedNeedsConsent: Bool! = false

	var needsConsent: Bool {
		invokedNeedsConsentGetter = true
		invokedNeedsConsentGetterCount += 1
		return stubbedNeedsConsent
	}

	var invokedFinishOnboarding = false
	var invokedFinishOnboardingCount = 0

	func finishOnboarding() {
		invokedFinishOnboarding = true
		invokedFinishOnboardingCount += 1
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
