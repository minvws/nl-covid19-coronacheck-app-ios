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
	@Bindable private(set) var pages: [NewFeatureItem]
	@Bindable private(set) var enabled: Bool
	
	init(
		coordinator: OnboardingCoordinatorDelegate,
		pages: [NewFeatureItem]) {
		
		self.coordinator = coordinator
		self.pages = pages
		self.enabled = true
	}
	
	/// Add an onboarding step
	/// - Parameter info: the info for the onboarding step
	func getStep(_ item: NewFeatureItem) -> UIViewController {
		
		let viewController = PagedAnnouncementItemViewController(
			viewModel: PagedAnnouncementItemViewModel(item: item)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}
	
	/// User has finished viewing the finished the pages
	func finish() {
		
		coordinator?.finishOnboarding()
	}
}
