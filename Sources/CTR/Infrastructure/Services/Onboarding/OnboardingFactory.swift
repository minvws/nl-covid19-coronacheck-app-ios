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
				title: .onboardingTitle1,
				message: .onboardingMessage1,
				image: .onboarding1,
				step: .safelyOnTheRoad
			),
			OnboardingPage(
				title: .onboardingTitle2,
				message: .onboardingMessage2,
				image: .onboarding2,
				step: .yourQR
			),
			OnboardingPage(
				title: .onboardingTitle3,
				message: .onboardingMessage3,
				image: .onboarding3,
				step: .validity
			),
			OnboardingPage(
				title: .onboardingTitle4,
				message: .onboardingMessage4,
				image: .onboarding4,
				step: .safeSystem
			),
			OnboardingPage(
				title: .onboardingTitle5,
				message: .onboardingMessage5,
				image: .onboarding5,
				step: .privacy
			)
		]
	}
}
