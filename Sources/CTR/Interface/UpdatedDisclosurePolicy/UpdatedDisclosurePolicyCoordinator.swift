/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol UpdatedDisclosurePolicyDelegate: AnyObject {

	func finishNewDisclosurePolicy()
}

class UpdatedDisclosurePolicyCoordinator: Coordinator {

	/// The child coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	let pagedAnnouncmentItems: [PagedAnnoucementItem]
	
	weak var delegate: UpdatedDisclosurePolicyDelegate?

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the new feature information delegate
	init(
		navigationController: UINavigationController,
		pagedAnnouncmentItems: [PagedAnnoucementItem],
		delegate: UpdatedDisclosurePolicyDelegate) {

		self.navigationController = navigationController
		self.pagedAnnouncmentItems = pagedAnnouncmentItems
		self.delegate = delegate
	}

	/// Start the scene
	func start() {

		logVerbose("Starting UpdatedDisclosurePolicy Flow")
		
		let multipaneMode: Bool = pagedAnnouncmentItems.count > 1
		
		let viewController = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: self,
				pages: pagedAnnouncmentItems,
				itemsShouldShowWithFullWidthHeaderImage: true,
				shouldShowWithVWSRibbon: false
			),
			allowsBackButton: multipaneMode,
			allowsCloseButton: !multipaneMode,
			allowsNextButton: true
		)
		
		let modalNavigationController = UINavigationController(rootViewController: viewController)
		modalNavigationController.modalPresentationStyle = .fullScreen
		navigationController.present(modalNavigationController, animated: true) {
			Current.disclosurePolicyManager.setDisclosurePolicyUpdateHasBeenSeen()
		}
	}

	// MARK: - Universal Link handling
	
	/// Override point for coordinators which wish to deal with universal links.
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

// MARK: - PagedAnnouncementDelegate

extension UpdatedDisclosurePolicyCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		navigationController.dismiss(animated: true) {
			Current.disclosurePolicyManager.setDisclosurePolicyUpdateHasBeenSeen()
			self.delegate?.finishNewDisclosurePolicy()
		}
	}
}
