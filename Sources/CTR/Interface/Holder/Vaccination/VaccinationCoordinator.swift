/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol VaccinationCoordinatorDelegate: AnyObject {

	/// The user did finish the vaccination scene
	func didFinish()
}

protocol VaccinationFlowDelegate: AnyObject {

	/// The vaccination flow is finished
	func finishVaccinationFlow()
}

class VaccinationCoordinator: Coordinator {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: VaccinationFlowDelegate?

	/// Initiailzer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the vaccination flow delegate
	init(
		navigationController: UINavigationController,
		delegate: VaccinationFlowDelegate) {

		self.navigationController = navigationController
		self.delegate = delegate
	}

	func start() {

		let viewController = VaccinationStartViewController(
			viewModel: VaccinationStartViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension VaccinationCoordinator: VaccinationCoordinatorDelegate {

	func didFinish() {
		
		delegate?.finishVaccinationFlow()
	}
}
