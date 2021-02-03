/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol OnboardingManagerProtocol {

	/// Do we need onboarding? True if we do
	var needsOnboarding: Bool { get }

	/// The onboarding is finished
	func finishOnboarding()

	/// Reset the manager
	func reset()
}

/// - Tag: OnboardingManager
class OnboardingManager: OnboardingManagerProtocol, Logging {

	var loggingCategory: String = "OnboardingManager"

	private struct OnboardingData: Codable {
		var needsOnboarding: Bool

		/// Empty crypto data
		static var empty: OnboardingData {
			return OnboardingData(needsOnboarding: true)
		}
	}

	private struct Constants {
		static let keychainService = "OnboardingManager"
	}

	@Keychain(name: "onboardingData", service: Constants.keychainService, clearOnReinstall: true)
	private var onboardingData: OnboardingData = .empty // swiftlint:disable:this let_var_whitespace

	/// Do we need onboarding? True if we do
	var needsOnboarding: Bool {

		return onboardingData.needsOnboarding
	}

	/// The onboarding is finished
	func finishOnboarding() {

		onboardingData.needsOnboarding = false
	}

	/// Reset the manager
	func reset() {

		$onboardingData.clearData()
	}
}
