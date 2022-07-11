/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol AlternativeRouteFlowDelegate: AnyObject {

	func canceledAlternativeRoute()
	
	func backToMyOverview()
	
	func continueToPap(eventMode: EventMode)
}

protocol AlternativeRouteCoordinatorDelegate: AnyObject {
	
	func userWishesToCheckForBSN()
	
	func userWishesToCheckForDigiD()
	
	func userWishesToRequestADigiD()
	
	func userWishesToEndAlternativeRoute(popViewController: Bool)
	
	func userWishesToContactHelpDeksWithBSN()
	
	func userWishesToContactHelpDeksWithoutBSN()
	
	func userHasNoBSN()
	
	func userWishedToGoToGGDPortal()
}

class AlternativeRouteCoordinator: Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: AlternativeRouteFlowDelegate?
	
	var eventMode: EventMode

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	init(navigationController: UINavigationController, delegate: AlternativeRouteFlowDelegate, eventMode: EventMode) {

		self.navigationController = navigationController
		self.delegate = delegate
		self.eventMode = eventMode
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
				coordinator: self,
				eventMode: eventMode
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
			openUrl(url, inApp: true)
		}
	}
	
	func userWishesToEndAlternativeRoute(popViewController: Bool) {
		
		if popViewController {
			navigationController.popViewController(animated: true)
		}
		delegate?.canceledAlternativeRoute()
	}

	func userWishesToContactHelpDeksWithBSN() {
		
		displayContent(
			title: L.holder_contactCoronaCheckHelpdesk_title(),
			message: L.holder_contactCoronaCheckHelpdesk_message()
		)
	}
	
	func userHasNoBSN() {
		
		if Current.featureFlagManager.isGGDPortalEnabled() {
			userWishesToChooseEventLocation()
		} else {
			userWishesToContactHelpDeksWithoutBSN()
		}
	}

	private func userWishesToChooseEventLocation() {
		
		let destination = ListOptionsViewController(
			viewModel: ChooseEventLocationViewModel(
				coordinator: self,
				eventMode: eventMode
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userWishesToContactHelpDeksWithoutBSN() {
		
		let message: String
		
		if Current.featureFlagManager.isGGDPortalEnabled() {
			message = L.holder_contactProviderHelpdesk_message_ggdPortalEnabled(eventMode == .vaccination ? L.holder_contactProviderHelpdesk_vaccinated() : L.holder_contactProviderHelpdesk_tested())
		} else {
			message = L.holder_contactProviderHelpdesk_message(eventMode == .vaccination ? L.holder_contactProviderHelpdesk_vaccinated() : L.holder_contactProviderHelpdesk_tested())
		}
		displayContent(title: L.holder_contactProviderHelpdesk_title(), message: message)
	}
	
	func userWishedToGoToGGDPortal() {
		
		delegate?.continueToPap(eventMode: eventMode)
	}
	
	private func displayContent(title: String, message: String) {
		
		let viewModel = ContentViewModel(
			content: Content(
				title: title,
				body: message,
				primaryActionTitle: L.general_toMyOverview(),
				primaryAction: { [weak self] in
					self?.delegate?.backToMyOverview()
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
}
