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
	case safeSystem
	case privacy
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

	/// The part of the text that should be underlined
	let underlinedText: String?
}

protocol OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [OnboardingPage]
}

struct OnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [OnboardingPage] {

		return [
			OnboardingPage(
				title: .onboardingTitleSafely,
				message: .onboardingMessageSafely,
				image: .onboardingSafely,
				step: .safelyOnTheRoad,
				underlinedText: nil
			),
			OnboardingPage(
				title: .onboardingTitleYourQR,
				message: .onboardingMessageYourQR,
				image: .onboardingYourQR,
				step: .yourQR,
				underlinedText: nil
			),
			OnboardingPage(
				title: .onboardingTitleValidity,
				message: .onboardingMessageValidity,
				image: .onboardingValidity,
				step: .validity,
				underlinedText: nil
			),
			OnboardingPage(
				title: .onboardingTitleSecureSystem,
				message: .onboardingMessageSecureSystem,
				image: .onboardingSecureSystem,
				step: .safeSystem,
				underlinedText: nil
			),
			OnboardingPage(
				title: .onboardingTitlePrivacy,
				message: .onboardingMessagePrivacy,
				image: .onboardingPrivacy,
				step: .privacy,
				underlinedText: .onboardingUnderlinePrivacy
			)
		]
	}
}
