/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The steps of the onboarding
enum OnboardingStep: Int {

	case safelyOnTheRoad
	case yourQR
	case validity
	case access
	case privacy
	case who
}

struct OnboardingPage {

	/// The title of the onboarding page
	let title: String

	/// The message of the onboarding page
	let message: String

	/// The image of the onboarding page
	let image: UIImage?

	/// The step of the onboarding page
	let step: OnboardingStep
}

protocol OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Parameter maxValidity: the maximum validity of a test in hours
	/// - Returns: an array of onboarding steps
	func create(maxValidity: Int) -> [OnboardingPage]

	/// Get the Consent Title
	func getConsentTitle() -> String

	/// Get the Consent message
	func getConsentMessage() -> String

	/// Get the Consent underlined message
	func getConsentLink() -> String

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String

	/// Get the consent Items
	func getConsentItems() -> [String]
}

struct HolderOnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Parameter maxValidity: the maximum validity of a test in hours
	/// - Returns: an array of onboarding steps
	func create(maxValidity: Int) -> [OnboardingPage] {

		let pages = [
			OnboardingPage(
				title: .holderOnboardingTitleSafely,
				message: .holderOnboardingMessageSafely,
				image: .onboardingSafely,
				step: .safelyOnTheRoad
			),
			OnboardingPage(
				title: .holderOnboardingTitleYourQR,
				message: .holderOnboardingMessageYourQR,
				image: .onboardingYourQR,
				step: .yourQR
			),
			OnboardingPage(
				title: .holderOnboardingTitleValidity,
				message: String(format: .holderOnboardingMessageValidity, "\(maxValidity)"),
				image: .onboardingValidity,
				step: .validity
			),
			OnboardingPage(
				title: .holderOnboardingTitlePrivacy,
				message: .holderOnboardingMessagePrivacy,
				image: .onboardingPrivacy,
				step: .who
			)
		]

		return pages.sorted { $0.step.rawValue < $1.step.rawValue }
	}

	/// Get the Consent Title
	func getConsentTitle() -> String {

		return .holderConsentTitle
	}

	/// Get the Consent message
	func getConsentMessage() -> String {

		return .holderConsentMessage
	}
	/// Get the Consent underlined message
	func getConsentLink() -> String {

		return .holderConsentMessageUnderlined
	}

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String {

		return .holderConsentButtonTitle
	}

	/// Get the consent Items
	func getConsentItems() -> [String] {

		return [
			.holderConsentItemOne,
			.holderConsentItemTwo
		]
	}
}

struct VerifierOnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Parameter maxValidity: the maximum validity of a test in hours
	/// - Returns: an array of onboarding steps
	func create(maxValidity: Int) -> [OnboardingPage] {

		let pages = [
			OnboardingPage(
				title: .verifierOnboardingTitleSafely,
				message: .verifierOnboardingMessageSafely,
				image: .onboardingSafely,
				step: .safelyOnTheRoad
			),
			OnboardingPage(
				title: .verifierOnboardingTitleScanQR,
				message: String(format: .verifierOnboardingMessageScanQR, "\(maxValidity)"),
				image: .onboardingScan,
				step: .yourQR
			),
			OnboardingPage(
				title: .verifierOnboardingTitleAccess,
				message: .verifierOnboardingMessageAccess,
				image: .onboardingPrivacy,
				step: .access
			),
			OnboardingPage(
				title: .verifierOnboardingTitleWho,
				message: .verifierOnboardingMessageWho,
				image: .onboardingWho,
				step: .privacy
			)
		]

		return pages.sorted { $0.step.rawValue < $1.step.rawValue }
	}

	/// Get the Consent Title
	func getConsentTitle() -> String {

		return .verifierConsentTitle
	}

	/// Get the Consent message
	func getConsentMessage() -> String {

		return .verifierConsentMessage
	}
	/// Get the Consent underlined message
	func getConsentLink() -> String {

		return .verifierConsentMessageUnderlined
	}

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String {

		return .verifierConsentButtonTitle
	}

	/// Get the consent Items
	func getConsentItems() -> [String] {

		return [
			.verifierConsentItemOne,
			.verifierConsentItemTwo,
			.verifierConsentItemThree
		]
	}
}
