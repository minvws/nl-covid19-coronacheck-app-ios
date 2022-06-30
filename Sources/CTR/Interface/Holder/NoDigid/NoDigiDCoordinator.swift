/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol NoDigiDCoordinatorDelegate: AnyObject {
	
	func userWishesToCheckForBSN()
	
	func userWishesToCheckForDigiD()
}

class NoDigiDCoordinator: Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: EventFlowDelegate?

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	init(navigationController: UINavigationController, eventMode: EventMode) {

		self.navigationController = navigationController
	}

	func start() {
		userWishesToCheckForDigiD()
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension NoDigiDCoordinator: NoDigiDCoordinatorDelegate {
	
	func userWishesToCheckForBSN() {
		
	}
	
	func userWishesToCheckForDigiD() {
		
		let destination = ListOptionsViewController(
			viewModel: CheckForDigidViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
}
