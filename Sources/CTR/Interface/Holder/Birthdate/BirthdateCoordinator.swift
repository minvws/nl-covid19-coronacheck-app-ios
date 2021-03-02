/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol BirthdateSceneDelegate: AnyObject {

	func birthdateConfirmed()
}

protocol BirthdateCoordinatorDelegate: AnyObject {

	// MARK: Navigation

	/// Navigate to Birthday entry Scene
	func navigateToBirthdayEntry()

	/// Navigate to Birthday confirmation Scene
	func navigateToBirthdayConfirmation(_ date: Date)

	/// Navigate back
	func navigateBackToBirthdayEntry()

	/// The user confirmed the birthdate
	func birthdateConfirmed()
}

class BirthdateCoordinator: Coordinator, Logging {

	var loggingCategory: String = "BirthdateCoordinator"

	/// The proof manager
	var proofManager: ProofManaging = Services.proofManager

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The navigation controller
	var presentingViewController: UIViewController?

	weak var birthdateSceneDelegate: BirthdateSceneDelegate?

	/// Initiatilzer
	init(
		navigationController: UINavigationController,
		presentingViewController: UIViewController?,
		birthdateSceneDelegate: BirthdateSceneDelegate) {

		self.navigationController = navigationController
		self.presentingViewController = presentingViewController
		self.birthdateSceneDelegate = birthdateSceneDelegate
	}

	// Designated starter method
	func start() {

		navigateToBirthdayEntry()
	}
}

// MARK: - HolderCoordinatorDelegate

extension BirthdateCoordinator: BirthdateCoordinatorDelegate {

	// MARK: Navigation

	/// Navigate to Birthday entry Scene
	func navigateToBirthdayEntry() {

		let destination = BirthdateEntryViewController(
			viewModel: BirthdateEntryViewModel(
				coordinator: self
			)
		)
		navigationController = UINavigationController(rootViewController: destination)
		presentingViewController?.present(navigationController, animated: true, completion: nil)
//		presentingViewController?.show(destination, sender: presentingViewController)
	}

	/// Navigate to Birthday confirmation Scene
	func navigateToBirthdayConfirmation(_ date: Date) {

		let destination = BirthdateConfirmationViewController(
			viewModel: BirthdateConfirmationViewModel(
				coordinator: self,
				proofManager: proofManager,
				date: date
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}

	/// Navigate back
	func navigateBackToBirthdayEntry() {

		navigationController.popToRootViewController(animated: true)
	}

	/// The user confirmed the birthdate
	func birthdateConfirmed() {

		dismiss()
		birthdateSceneDelegate?.birthdateConfirmed()
	}
}

// MARK: - Dismissable

extension BirthdateCoordinator: Dismissable {

	func dismiss() {

		presentingViewController?.dismiss(animated: true, completion: nil)
	}
}
