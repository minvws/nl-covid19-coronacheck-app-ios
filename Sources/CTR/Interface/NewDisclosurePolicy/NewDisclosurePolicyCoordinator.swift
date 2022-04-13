/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol NewDisclosurePolicyDelegate: AnyObject {

	func finishNewDisclosurePolicy()
}

// TODO: rename "..announcement"
class NewDisclosurePolicyCoordinator: Coordinator, Logging {

	/// The child coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	let pagedAnnouncmentItems: [NewFeatureItem]
	
	weak var delegate: NewDisclosurePolicyDelegate?

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the new feature information delegate
	init(
		navigationController: UINavigationController,
		pagedAnnouncmentItems: [NewFeatureItem],
		delegate: NewDisclosurePolicyDelegate) {

		self.navigationController = navigationController
		self.pagedAnnouncmentItems = pagedAnnouncmentItems
		self.delegate = delegate
	}

	/// Start the scene
	func start() {

		logVerbose("Starting NewDisclosurePolicy Flow")
		
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
			allowsNextButton: multipaneMode
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

extension NewDisclosurePolicyCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		navigationController.dismiss(animated: true) {
			Current.disclosurePolicyManager.setDisclosurePolicyUpdateHasBeenSeen()
			self.delegate?.finishNewDisclosurePolicy()
		}
	}
}
