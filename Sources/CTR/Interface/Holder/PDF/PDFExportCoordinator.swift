/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Models
import ReusableViews
import Shared
import UIKit

protocol PDFExportFlowDelegate: AnyObject {

	func exportCompleted()
}

class PDFExportCoordinator: NSObject, Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: PDFExportFlowDelegate?

	var startPagesFactory: StartPDFExportFactoryProtocol = StartPDFExportFactory()

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the pdf export flow delegate
	init(navigationController: UINavigationController, delegate: PDFExportFlowDelegate) {

		self.navigationController = navigationController
		self.delegate = delegate
		super.init()
		self.navigationController.delegate = self
	}

	func start() {
		
		let viewController = PagedAnnouncementViewController(
			title: nil,
			viewModel: PagedAnnouncementViewModel(
				delegate: self,
				pages: startPagesFactory.getExportInstructions(),
				itemsShouldShowWithFullWidthHeaderImage: true,
				shouldShowWithVWSRibbon: false,
				enableSwipeBack: true
			),
			allowsPreviousPageButton: true,
			allowsCloseButton: false,
			allowsNextPageButton: true) { [weak self] in
				// Remove from the navigation stack
				self?.navigationController.popViewController(animated: true)
			}
		navigationController.pushViewController(viewController, animated: true)
	}
	
	// MARK: - Universal Link handling

	func consume(universalLink: Models.UniversalLink) -> Bool {

		return false
	}
}

// MARK: - PagedAnnouncementDelegate

extension PDFExportCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		logDebug("PDFExportCoordinator - PagedAnnouncementDelegate - didFinishPagedAnnouncement")
	}
}

// MARK: - UINavigationControllerDelegate

extension PDFExportCoordinator: UINavigationControllerDelegate {

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

		if !navigationController.viewControllers.contains(where: { $0.isKind(of: PagedAnnouncementViewController.self) }) {
			// If there is no more ContentWithIconViewController in the stack, we are done here.
			// Works for both back swipe and back button
			delegate?.exportCompleted()
		}
	}
}
