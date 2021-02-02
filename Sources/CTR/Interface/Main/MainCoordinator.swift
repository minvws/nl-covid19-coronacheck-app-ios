/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol MainCoordinatorDelegate: AnyObject {

	/// Navigate to the holder flow
	func navigateToHolder()

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

	/// The corona Test Proof Model
	let coronaTestProof = CTRModel()

	// Designated starter method
	func start() {

		guard !ProcessInfo.processInfo.isTesting else {
			// do not launc when unit testing
			return
		}

		// Start the CoronaTestProof
		coronaTestProof.populate()

		navigationController.delegate = self
		let viewController = MainViewController(
			viewModel: MainViewModel(
				coordinator: self
			)
		)
		navigationController.setViewControllers([viewController], animated: true)
	}
}

extension MainCoordinator: MainCoordinatorDelegate {

	/// Navigate to the holder flow
	func navigateToHolder() {

		let coordinator = HolderCoordinator(navigationController: navigationController)
		coordinator.coronaTestProof = coronaTestProof
		startChildCoordinator(coordinator)
	}

	/// Navigate toe the verifier flow
	func navigateToVerifier() {

		let coordinator = VerifierCoordinator(navigationController: navigationController)
		coordinator.coronaTestProof = coronaTestProof
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

		if fromViewController is VerifierStartViewController || fromViewController is HolderStartViewController {
			childCoordinators = []
		}
	}
}
