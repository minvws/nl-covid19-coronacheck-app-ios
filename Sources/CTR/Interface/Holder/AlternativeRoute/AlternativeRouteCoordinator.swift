/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol AlternativeRouteFlowDelegate: AnyObject {

	func canceledAlternativeRoute()
	
	func completedAlternativeRoute()
}

protocol AlternativeRouteCoordinatorDelegate: AnyObject {
	
	func userWishesToCheckForBSN()
	
	func userWishesToCheckForDigiD()
	
	func userWishesToRequestADigiD()
	
	func userWishesToEndAlternativeRoute()
	
	func userWishesToContactHelpDeksWithBSN()

	func userWishesToContactHelpDeksWithoutBSN()

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
		
		let destination = ListOptionsViewController(
			viewModel: CheckForBSNViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
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
		
		delegate?.canceledAlternativeRoute()
	}

	func userWishesToContactHelpDeksWithBSN() {
		Current.logHandler.logDebug("userWishesToContactHelpDeksWithBSN")
		
		let viewModel = ContentViewModel(
			content: Content(
				title: L.holder_contactCoronaCheckHelpdesk_title(),
				body: L.holder_contactCoronaCheckHelpdesk_message(),
				primaryActionTitle: L.general_toMyOverview(),
				primaryAction: { [weak self] in
					self?.delegate?.completedAlternativeRoute()
				}
			),
			backAction: { [weak navigationController] in
				navigationController?.popViewController(animated: true, completion: {})
			},
			allowsSwipeBack: true,
			linkTapHander: { [weak self] url in
				self?.openUrl(url, inApp: true)
			}
		)
		
		let destination = ContentViewController(viewModel: viewModel)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userWishesToContactHelpDeksWithoutBSN() {
		Current.logHandler.logDebug("userWishesToContactHelpDeksWithoutBSN")
	}
}

/**

 holder_contactProviderHelpdesk_title
 holder_contactProviderHelpdesk_message
 holder_contactProviderHelpdesk_testLocation
 holder_contactProviderHelpdesk_vaccinationLocation
 holder_contactProviderHelpdesk_tested
 holder_contactProviderHelpdesk_vaccinated
 general_toMyOverview
 
*/
