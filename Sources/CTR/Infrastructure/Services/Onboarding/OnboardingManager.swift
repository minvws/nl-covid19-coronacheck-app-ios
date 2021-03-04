/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol OnboardingManaging {

	// Initialize
	init()

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
	private struct OnboardingData: Codable {

		/// The user needs to do the onboarding
		var needsOnboarding: Bool

		/// The user needs to give consent
		var needsConsent: Bool

		/// Empty crypto data
		static var empty: OnboardingData {
			return OnboardingData(needsOnboarding: true, needsConsent: true)
		}
	}

	private struct Constants {

		/// The key chain service
		static let keychainService = "OnboardingManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	// keychained onboardings data
	@Keychain(name: "onboardingData", service: Constants.keychainService, clearOnReinstall: true)
	private var onboardingData: OnboardingData = .empty

	/// Initializer
	required init() {
		// Required by protocol
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

		$onboardingData.clearData()
	}
}
