/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol MainCoordinatorDelegate: AnyObject {

	/// Navigate to the customer flow
	func navigateToCustomer()

	/// Navigate toe the verifier flow
	func navigateToVerifier()
}

class MainCoordinator: NSObject, Coordinator {

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// Initiatilzer
	init(navigationController: UINavigationController) {

		self.navigationController = navigationController
	}

	// Designated starter method
	func start() {

		navigationController.delegate = self
		let viewController = MainViewController()
		viewController.coordinator = self
		navigationController.setViewControllers([viewController], animated: true)
	}
}

extension MainCoordinator: MainCoordinatorDelegate {

	/// Navigate to the customer flow
	func navigateToCustomer() {

		let coordinator = CustomerCoordinator(navigationController: navigationController)
		startChildCoordinator(coordinator)
	}

	/// Navigate toe the verifier flow
	func navigateToVerifier() {

		let coordinator = VerifierCoordinator(navigationController: navigationController)
		startChildCoordinator(coordinator)
	}
}

// MARK: - UINavigationControllerDelegate

extension MainCoordinator: UINavigationControllerDelegate {

	func navigationController(
		_ navigationController: UINavigationController,
		didShow viewController: UIViewController,
		animated: Bool) {

		guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
			return
		}

		if navigationController.viewControllers.contains(fromViewController) {
			return
		}

		if fromViewController is VerifierStartViewController || fromViewController is CustomerStartViewController {
			childCoordinators = []
		}
	}
}
