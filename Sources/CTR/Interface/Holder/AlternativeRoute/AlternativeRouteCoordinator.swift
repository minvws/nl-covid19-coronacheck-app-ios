/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol AlternativeRouteFlowDelegate: AnyObject {

	func completedAlternativeRoute()
}

protocol AlternativeRouteCoordinatorDelegate: AnyObject {
	
	func userWishesToCheckForBSN()
	
	func userWishesToCheckForDigiD()
	
	func userWishesToRequestADigiD()
	
	func userWishesToEndAlternativeRoute()

}

class AlternativeRouteCoordinator: Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: AlternativeRouteFlowDelegate?

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	init(navigationController: UINavigationController, delegate: AlternativeRouteFlowDelegate, eventMode: EventMode) {

		self.navigationController = navigationController
		self.delegate = delegate
	}

	func start() {
		userWishesToCheckForDigiD()
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension AlternativeRouteCoordinator: AlternativeRouteCoordinatorDelegate {
	
	func userWishesToCheckForBSN() {
		
	}
	
	func userWishesToCheckForDigiD() {
		
		let destination = CheckForDigidViewController(
			viewModel: CheckForDigidViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userWishesToRequestADigiD() {
		if let url = URL(string: L.holder_noDigiD_url()) {
			openUrl(url, inApp: false)
		}
	}
	
	func userWishesToEndAlternativeRoute() {
		
		delegate?.completedAlternativeRoute()
	}
}
