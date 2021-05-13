/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum VaccinationFlowResult {

	case stop

	case continu
}

protocol VaccinationCoordinatorDelegate: AnyObject {

	func didFinishStart(_ result: VaccinationFlowResult)

	func didFinishLoad(_ result: VaccinationFlowResult)
}

protocol VaccinationFlowDelegate: AnyObject {

	/// The vaccination flow is finished
	func finishVaccinationFlow()
}

class VaccinationCoordinator: Coordinator, Logging {

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

	private func navigateToLoad(_ token: String = "999999011") {

		let viewController = FetchEventsViewController(
			viewModel: FetchEventsViewModel(
				coordinator: self,
				tvsToken: token
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
}

extension VaccinationCoordinator: VaccinationCoordinatorDelegate {

	func didFinishStart(_ result: VaccinationFlowResult) {

		switch result {
			case .stop:
				delegate?.finishVaccinationFlow()
			case .continu:
				navigateToLoad()
		}
	}


	func didFinishLoad(_ result: VaccinationFlowResult) {

		switch result {
			case .stop:
				delegate?.finishVaccinationFlow()
			case .continu:
				logInfo("To be implemented")
		}
	}
}
