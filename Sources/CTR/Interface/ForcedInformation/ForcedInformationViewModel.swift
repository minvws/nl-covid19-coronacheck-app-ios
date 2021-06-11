/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ForcedInformationViewModel {
	
	/// Coordination Delegate
	weak var coordinator: ForcedInformationCoordinatorDelegate?
	
	/// The pages
	@Bindable private(set) var pages: [ForcedInformationPage]
	
	init(
		coordinator: ForcedInformationCoordinatorDelegate,
		pages: [ForcedInformationPage]) {
		
		self.coordinator = coordinator
		self.pages = pages
	}
	
	func getForcedInformatioStep(_ info: ForcedInformationPage) -> UIViewController {
		
		let viewController = ForcedInformationPageViewController(
			viewModel: ForcedInformationPageViewModel(
				coordinator: coordinator!,
				forcedInfo: info
			)
		)
		return viewController
	}
	
	func finish(_ result: ForcedInformationResult) {
		
		coordinator?.didFinish(result)
	}
}
