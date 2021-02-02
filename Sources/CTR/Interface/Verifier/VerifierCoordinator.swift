/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol VerifierCoordinatorDelegate: AnyObject {

	// Navigate to the Scan Scene
	func navigateToScan()

	// Navigate to the Scan Result
	func navigateToScanResult()

	/// Navigate to the start fo the verifier flow
	func navigateToStart()

	/// Set the scan result
	/// - Parameter result: True if valid
	func setScanResult(_ result: Bool)

	/// Dismiss the viewcontroller
	func dismiss()
}

class VerifierCoordinator: Coordinator {

	var isValid: Bool = false

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

		let viewController = VerifierStartViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {

	// Navigate to the Scan Scene
	func navigateToScan() {

		let viewController = VerifierScanViewController(viewModel: VerifierScanViewModel(coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Test Result
	func navigateToScanResult() {

		let viewController = VerifierResultViewController(
			viewModel: VerifierResultViewModel(
				coordinator: self,
				result: isValid
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	/// Set the scan result
	/// - Parameter result: True if valid
	func setScanResult(_ result: Bool) {

		isValid = result
	}

	/// Navigate to the start fo the verifier flow
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
