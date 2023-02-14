/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public protocol OnboardingManaging: AnyObject {

	/// Do we need onboarding? True if we do
	var needsOnboarding: Bool { get }

	/// Do we need conset? True if we do
	var needsConsent: Bool { get }

	/// The onboarding is finished
	func finishOnboarding()

	/// Give consent
	func consentGiven()

	/// Reset the manager
	func wipePersistedData()
}

/// - Tag: OnboardingManager
public class OnboardingManager: OnboardingManaging {

	/// The onboarding data to persist
	public struct OnboardingData: Codable {

		/// The user needs to do the onboarding
		public var needsOnboarding: Bool

		/// The user needs to give consent
		public var needsConsent: Bool

		/// Empty crypto data
		public static var empty: OnboardingData {
			return OnboardingData(needsOnboarding: true, needsConsent: true)
		}
	}

	// keychained onboardings data
	private var onboardingData: OnboardingData {
		get { secureUserSettings.onboardingData }
		set { secureUserSettings.onboardingData = newValue }
	}

	private let secureUserSettings: SecureUserSettingsProtocol

	public required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}

	/// Do we need onboarding? True if we do
	public var needsOnboarding: Bool {

		return onboardingData.needsOnboarding
	}

	/// Do we need consent? True if we do
	public var needsConsent: Bool {

		return onboardingData.needsConsent
	}

	/// The onboarding is finished
	public func finishOnboarding() {

		onboardingData.needsOnboarding = false
	}

	/// Give consent
	public func consentGiven() {

		onboardingData.needsConsent = false
	}

	/// Reset the manager
	public func wipePersistedData() {

		secureUserSettings.onboardingData = SecureUserSettings.Defaults.onboardingData
	}
}
