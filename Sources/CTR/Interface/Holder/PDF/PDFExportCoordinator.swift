/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckUI
import Models

protocol PDFExportFlowDelegate: AnyObject {

	func exportCompleted()
	
	func exportFailed()
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
		
		userWishesToStart()
	}
	
	// MARK: - Universal Link handling
	
	func consume(universalLink: Models.UniversalLink) -> Bool {
		
		return false
	}
}

protocol PDFExportCoordinatorDelegate: AnyObject {
	
	func userWishesToStart()
	
	func userWishesToExport()
	
	func displayError(content: Content)
	
	func userWishesToShare(_ path: URL, sender: UIView?)
	
	func exportFailed()
}

extension PDFExportCoordinator: PDFExportCoordinatorDelegate {
	
	func userWishesToStart() {
		
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
	
	func userWishesToExport() {
		
		// Go to consent
		let viewController = PDFExportViewController(
			viewModel: PDFExportViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func displayError(content: Content) {
		
		presentContent(content: content)
	}
	
	func userWishesToShare(_ path: URL, sender: UIView?) {
		
		let items: [Any] = [path]
		let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
		
		if let sender, UIDevice.current.userInterfaceIdiom == .pad {
			activityViewController.popoverPresentationController?.sourceRect = sender.bounds
			activityViewController.popoverPresentationController?.sourceView = sender
		}
		navigationController.present(activityViewController, animated: true)
	}
	
	func exportFailed() {

		delegate?.exportFailed()
	}
}

// MARK: - PagedAnnouncementDelegate

extension PDFExportCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		userWishesToExport()
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
