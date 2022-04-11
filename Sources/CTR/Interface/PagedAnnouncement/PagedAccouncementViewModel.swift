/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PagedAnnouncementViewModel {
	
	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?
	
	/// The pages for onboarding
	@Bindable private(set) var pages: [OnboardingPage]
	@Bindable private(set) var enabled: Bool
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: OnboardingCoordinatorDelegate,
		pages: [OnboardingPage]) {
		
		self.coordinator = coordinator
		self.pages = pages
		self.enabled = true
	}
	
	/// Add an onboarding step
	/// - Parameter info: the info for the onboarding step
	func getOnboardingStep(_ info: OnboardingPage) -> UIViewController {
		
		let viewController = PagedAnnouncementItemViewController(
			viewModel: PagedAnnouncementItemViewModel(
				coordinator: self.coordinator!,
				onboardingInfo: info
			)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}
	
	/// We have finished the onboarding
	func finishOnboarding() {
		
		coordinator?.finishOnboarding()
	}
}
