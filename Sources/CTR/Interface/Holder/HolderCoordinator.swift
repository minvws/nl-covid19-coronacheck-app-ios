/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol HolderCoordinatorDelegate: AnyObject {

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults()

	// Navigate to the Generate Holder QR Scene
	func navigateToHolderQR()

	/// Navigate to the start fo the holder flow
	func navigateToStart()

	/// Dismiss the viewcontroller
	func dismiss()
}

class HolderCoordinator: Coordinator {

	var coronaTestProof: CTRModel?

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

		let viewController = HolderStartViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults() {

		let viewController = HolderFetchResultViewController(
			viewModel: FetchResultViewModel(
				coordinator: self,
				openIdClient: OpenIdClient(configuration: Configuration()),
				userIdentifier: coronaTestProof?.userIdentifier
			)
		)

		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Generate Holder QR Scene
	func navigateToHolderQR() {

		let viewController = HolderGenerateQRViewController(viewModel: GenerateQRViewModel(coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	/// Navigate to the start fo the holder flow
	func navigateToStart() {

		guard navigationController.viewControllers.count > 1 else {
			return
		}
		navigationController.popToViewController(navigationController.viewControllers[1], animated: true)
	}

	/// Dismiss the viewcontroller
	func dismiss() {

		navigationController.popViewController(animated: true)
	}
}
