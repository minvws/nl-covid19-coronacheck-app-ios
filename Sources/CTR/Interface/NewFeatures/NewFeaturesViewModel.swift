/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class NewFeaturesViewModel {
	
	/// Coordination Delegate
	weak var coordinator: NewFeaturesCoordinatorDelegate?
	
	/// The pages
	@Bindable private(set) var pages: [NewFeatureItem]
	
	init(
		coordinator: NewFeaturesCoordinatorDelegate,
		pages: [NewFeatureItem]) {
		
		self.coordinator = coordinator
		self.pages = pages
	}
	
	func getNewFeatureStep(_ info: NewFeatureItem) -> UIViewController {
		
		let viewController = NewFeaturesItemViewController(
			viewModel: PagedAnnouncementItemViewModel(newFeatureItem: info)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}
	
	func finish(_ result: NewFeaturesScreenResult) {
		
		coordinator?.didFinish(result)
	}
}
