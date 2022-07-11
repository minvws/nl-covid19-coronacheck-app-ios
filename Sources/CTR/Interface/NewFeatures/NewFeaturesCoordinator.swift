/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol NewFeaturesDelegate: AnyObject {

	/// The new feature information flow is finished
	func finishNewFeatures()
}

class NewFeaturesCoordinator: Coordinator {

	/// The child coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The new features manager
	var newFeaturesManager: NewFeaturesManaging

	/// The new feature information delegate
	weak var delegate: NewFeaturesDelegate?

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - newFeaturesManager: the new features manager
	///   - delegate: the new feature information delegate
	init(
		navigationController: UINavigationController,
		newFeaturesManager: NewFeaturesManaging,
		delegate: NewFeaturesDelegate) {

		self.navigationController = navigationController
		self.newFeaturesManager = newFeaturesManager
		self.delegate = delegate
	}

	/// Start the scene
	func start() {

		Current.logHandler.logVerbose("Starting New Features Information Flow")
		
		if let pagedAnnouncementItems = newFeaturesManager.pagedAnnouncementItems() {
			
			let viewController = PagedAnnouncementViewController(
				viewModel: PagedAnnouncementViewModel(
					delegate: self,
					pages: pagedAnnouncementItems,
					itemsShouldShowWithFullWidthHeaderImage: true,
					shouldShowWithVWSRibbon: false
				),
				allowsBackButton: false,
				allowsCloseButton: pagedAnnouncementItems.count == 1,
				allowsNextButton: true
			)
			navigationController.viewControllers = [viewController]
			navigationController.view.window?.replaceRootViewController(with: navigationController)
		} else {

			// no update required
			delegate?.finishNewFeatures()
		}
	}

	// MARK: - Universal Link handling
	
	/// Override point for coordinators which wish to deal with universal links.
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

// MARK: - PagedAnnouncementDelegate

extension NewFeaturesCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		delegate?.finishNewFeatures()
	}
}
