/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

// MARK: - Test Doubles

class OnboardingCoordinatorSpy: OnboardingCoordinatorDelegate {

	var finishOnboardingCalled = false
	var dismissCalled = false
	var showPrivacyPageCalled = false
	var consentGivenCalled = false
	var navigateToConsentCalled = false

	func dismiss() {

		dismissCalled = true
	}

	func showPrivacyPage() {

		showPrivacyPageCalled = true
	}

	func finishOnboarding() {

		finishOnboardingCalled = true
	}

	func consentGiven() {

		consentGivenCalled = true
	}

	func navigateToConsent() {

		navigateToConsentCalled = true
	}
}
