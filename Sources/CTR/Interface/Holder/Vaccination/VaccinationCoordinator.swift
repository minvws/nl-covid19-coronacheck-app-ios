/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum VaccinationScreenResult: Equatable {

	/// The user wants to go back a scene
	case back

	/// Stop with vaccination flow,
	case stop

	/// Continue with the next step in the flow
	case `continue`

	/// Show the details of a vaccination event
	case details(Vaccination.Event, Vaccination.Identity)
}

protocol VaccinationCoordinatorDelegate: AnyObject {

	func vaccinationStartScreenDidFinish(_ result: VaccinationScreenResult)

	func fetchEventsScreenDidFinish(_ result: VaccinationScreenResult)
}

protocol VaccinationFlowDelegate: AnyObject {

	/// The vaccination flow is finished
	func vaccinationFlowDidComplete()

	func vaccinationFlowDidCancel()
}

class VaccinationCoordinator: Coordinator, Logging {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: VaccinationFlowDelegate?

	private var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate() // swiftlint:disable:this weak_delegate

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

	private func navigateToVaccinationEventDetails(_ title: String, body: String) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body
			)
		)

		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		navigationController.visibleViewController?.present(viewController, animated: true, completion: nil)
		
	}
}

extension VaccinationCoordinator: Dismissable {

	func dismiss() {

		navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
	}
}

extension VaccinationCoordinator: VaccinationCoordinatorDelegate {

	func vaccinationStartScreenDidFinish(_ result: VaccinationScreenResult) {

		switch result {
			case .back, .stop:
				delegate?.vaccinationFlowDidCancel()
			case .continue:
				// When the digid login is fixed, the default 999999011 should be removed.
				// Until then, this is the only fake BSN to use to get vaccination events
				// TODO: Remove default value // swiftlint:disable:this todo
				navigateToFetchEvents(token: "999999011")
			default:
				break
		}
	}

	func fetchEventsScreenDidFinish(_ result: VaccinationScreenResult) {

		switch result {
			case .stop:
				delegate?.vaccinationFlowDidComplete()
			case .continue:
				logInfo("To be implemented")
			case .back:
				if let vaccineStartViewController = navigationController.viewControllers
					.first(where: { $0 is VaccinationStartViewController }) {

					navigationController.popToViewController(
						vaccineStartViewController,
						animated: true
					)
				}
			//			case let .details(event, identity):
			// Todo: Populate the .holderVaccinationAboutBody with the right details from event and identity.
			// Copy is not final, so just a placeholder.
			case .details:

				navigateToVaccinationEventDetails(.holderVaccinationAboutTitle, body: .holderVaccinationAboutBody)
		}
	}
}
