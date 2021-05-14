/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum VaccinationScreenResult {

	/// Stop with vaccination flow,
	case stop

	/// Continue with the next step in the flow
	case `continue`
}

protocol VaccinationCoordinatorDelegate: AnyObject {

	func vaccinationStartScreenDidFinish(_ result: VaccinationScreenResult)

	func fetchEventsScreenDidFinish(_ result: VaccinationScreenResult)
}

protocol VaccinationFlowDelegate: AnyObject {

	/// The vaccination flow is finished
	func vaccinationFlowDidComplete()
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

	// MARK: Private functions

	private func navigateToFetchEvents(token: String) {
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

	func vaccinationStartScreenDidFinish(_ result: VaccinationScreenResult) {

		switch result {
			case .stop:
				delegate?.vaccinationFlowDidComplete()
			case .continue:
				// When the digid login is fixed, the default 999999011 should be removed.
				// Until then, this is the only fake BSN to use to get vaccination events
				// TODO: Remove default value // swiftlint:disable:this todo
				navigateToFetchEvents(token: "999999011")
		}
	}

	func fetchEventsScreenDidFinish(_ result: VaccinationScreenResult) {

		switch result {
			case .stop:
				delegate?.vaccinationFlowDidComplete()
			case .continue:
				logInfo("To be implemented")
		}
	}
}
