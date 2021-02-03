/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var pageNumber: Int
	@Bindable private(set) var numberOfPages: Int

	var step: OnboardingStep
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: OnboardingCoordinatorDelegate,
		onboardingInfo: OnboardingPage,
		numberOfPages: Int) {

		self.coordinator = coordinator

		title = onboardingInfo.title
		message = onboardingInfo.message
		image = onboardingInfo.image
		pageNumber = onboardingInfo.step.rawValue
		self.numberOfPages = numberOfPages
		self.step = onboardingInfo.step
	}

	/// The user clicked on the next button
	func nextButtonClicked() {

		// Notify the coordinator
		coordinator?.nextButtonClicked(step: step)
	}
}
