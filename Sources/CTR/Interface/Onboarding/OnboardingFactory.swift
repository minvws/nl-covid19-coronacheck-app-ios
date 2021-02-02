/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum OnboardingStep: Int {

	case safelyOnTheRoad
	case yourQR
	case validity
	case safeSystem
	case privacy
}

struct OnboardingInfo {

	let title: String
	let message: String
	let image: UIImage?
	let step: OnboardingStep
}

protocol OnboardingFactoryProtocol {

	func generate() -> [OnboardingInfo]
}

struct OnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func generate() -> [OnboardingInfo] {

		return [
			OnboardingInfo(
				title: .onboardingTitle1,
				message: .onboardingMessage1,
				image: .onboarding1,
				step: .safelyOnTheRoad
			),
			OnboardingInfo(
				title: .onboardingTitle2,
				message: .onboardingMessage2,
				image: .onboarding2,
				step: .yourQR
			),
			OnboardingInfo(
				title: .onboardingTitle3,
				message: .onboardingMessage3,
				image: .onboarding3,
				step: .validity
			),
			OnboardingInfo(
				title: .onboardingTitle4,
				message: .onboardingMessage4,
				image: .onboarding4,
				step: .safeSystem
			),
			OnboardingInfo(
				title: .onboardingTitle5,
				message: .onboardingMessage5,
				image: .onboarding5,
				step: .privacy
			)
		]
	}
}
