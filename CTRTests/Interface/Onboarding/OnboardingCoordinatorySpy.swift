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

	var invokedShowPrivacyPage = false
	var invokedShowPrivacyPageCount = 0

	func showPrivacyPage() {
		invokedShowPrivacyPage = true
		invokedShowPrivacyPageCount += 1
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}

	var invokedFinishOnboarding = false
	var invokedFinishOnboardingCount = 0

	func finishOnboarding() {
		invokedFinishOnboarding = true
		invokedFinishOnboardingCount += 1
	}

	var invokedNavigateToConsent = false
	var invokedNavigateToConsentCount = 0
	var invokedNavigateToConsentParameters: (hideBackButton: Bool, Void)?
	var invokedNavigateToConsentParametersList = [(hideBackButton: Bool, Void)]()

	func navigateToConsent(hideBackButton: Bool) {
		invokedNavigateToConsent = true
		invokedNavigateToConsentCount += 1
		invokedNavigateToConsentParameters = (hideBackButton, ())
		invokedNavigateToConsentParametersList.append((hideBackButton, ()))
	}

	var invokedConsentGiven = false
	var invokedConsentGivenCount = 0

	func consentGiven() {
		invokedConsentGiven = true
		invokedConsentGivenCount += 1
	}
}
