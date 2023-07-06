/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

public class OnboardingManagerSpy: OnboardingManaging {
	
	public init() {}

	public var invokedNeedsOnboardingGetter = false
	public var invokedNeedsOnboardingGetterCount = 0
	public var stubbedNeedsOnboarding: Bool! = false

	public var needsOnboarding: Bool {
		invokedNeedsOnboardingGetter = true
		invokedNeedsOnboardingGetterCount += 1
		return stubbedNeedsOnboarding
	}

	public var invokedNeedsConsentGetter = false
	public var invokedNeedsConsentGetterCount = 0
	public var stubbedNeedsConsent: Bool! = false

	public var needsConsent: Bool {
		invokedNeedsConsentGetter = true
		invokedNeedsConsentGetterCount += 1
		return stubbedNeedsConsent
	}

	public var invokedFinishOnboarding = false
	public var invokedFinishOnboardingCount = 0

	public func finishOnboarding() {
		invokedFinishOnboarding = true
		invokedFinishOnboardingCount += 1
	}

	public var invokedConsentGiven = false
	public var invokedConsentGivenCount = 0

	public func consentGiven() {
		invokedConsentGiven = true
		invokedConsentGivenCount += 1
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
