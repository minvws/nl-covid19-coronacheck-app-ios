/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingPageViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var underlinedText: String?
	@Bindable private(set) var image: UIImage?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	init(
		coordinator: OnboardingCoordinatorDelegate,
		onboardingInfo: OnboardingPage) {

		self.coordinator = coordinator
		title = onboardingInfo.title
		message = onboardingInfo.message
		image = onboardingInfo.image
		underlinedText = onboardingInfo.underlinedText
	}

	/// Show the privacy page
	/// - Parameter viewController: the presenting viewcontroller
	func linkClicked(_ viewController: UIViewController) {
		
		coordinator?.showPrivacyPage(viewController)
	}
}
