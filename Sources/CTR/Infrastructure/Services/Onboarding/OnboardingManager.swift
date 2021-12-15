/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol OnboardingManaging: AnyObject {

	// Initialize
	init(secureUserSettings: SecureUserSettingsProtocol)

	/// Do we need onboarding? True if we do
	var needsOnboarding: Bool { get }

	/// Do we need conset? True if we do
	var needsConsent: Bool { get }

	/// The onboarding is finished
	func finishOnboarding()

	/// Give consent
	func consentGiven()

	/// Reset the manager
	func reset()
}

/// - Tag: OnboardingManager
class OnboardingManager: OnboardingManaging, Logging {

	var loggingCategory: String = "OnboardingManager"

	/// The onboarding data to persist
	struct OnboardingData: Codable {

		/// The user needs to do the onboarding
		var needsOnboarding: Bool

		/// The user needs to give consent
		var needsConsent: Bool

		/// Empty crypto data
		static var empty: OnboardingData {
			return OnboardingData(needsOnboarding: true, needsConsent: true)
		}
	}

	// keychained onboardings data
	private var onboardingData: OnboardingData {
		get { secureUserSettings.onboardingData }
		set { secureUserSettings.onboardingData = newValue }
	}

	private let secureUserSettings: SecureUserSettingsProtocol

	required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}

	/// Do we need onboarding? True if we do
	var needsOnboarding: Bool {

		return onboardingData.needsOnboarding
	}

	/// Do we need consent? True if we do
	var needsConsent: Bool {

		return onboardingData.needsConsent
	}

	/// The onboarding is finished
	func finishOnboarding() {

		onboardingData.needsOnboarding = false
	}

	/// Give consent
	func consentGiven() {

		onboardingData.needsConsent = false
	}

	/// Reset the manager
	func reset() {

		SecureUserSettings().$onboardingData.clearData()
	}
}
