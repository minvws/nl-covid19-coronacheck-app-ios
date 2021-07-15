/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol PaperCertificateFlowDelegate: AnyObject {
	
	func addCertificateFlowDidFinish()
}

protocol PaperCertificateCoordinatorDelegate: AnyObject {
	func userDidSubmitPaperCertificateToken(token: String)

	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool)
}

final class PaperCertificateCoordinator: Coordinator, Logging {
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController = UINavigationController()

	weak var delegate: PaperCertificateFlowDelegate?

	fileprivate var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate() // swiftlint:disable:this weak_delegate

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	init(delegate: PaperCertificateFlowDelegate) {
		
		self.delegate = delegate
	}
	
	/// Start the scene
	func start() {
		// Not implemented. Starts in holder coordinator
	}
	
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
	
	func navigateToTokenEntry() {

		let destination = PaperCertificateTokenEntryViewController(
			viewModel: PaperCertificateTokenEntryViewModel(coordinator: self)
		)

		navigationController.pushViewController(destination, animated: true)

	}
}

extension PaperCertificateCoordinator: PaperCertificateCoordinatorDelegate {

	func userDidSubmitPaperCertificateToken(token: String) {
		// implement
	}

	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		navigationController.viewControllers.last?.present(viewController, animated: true, completion: nil)
	}
}

// MARK: - Dismissable

extension PaperCertificateCoordinator: Dismissable {

	func dismiss() {

		if navigationController.presentedViewController != nil {
			navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
		} else {
			navigationController.popViewController(animated: false)
		}
	}
}

// MARK: - OpenUrlProtocol

extension PaperCertificateCoordinator: OpenUrlProtocol {

	/// Open a url
	/// - Parameters:
	///   - url: The url to open
	///   - inApp: True if we should open the url in a in-app browser, False if we want the OS to handle the url
	func openUrl(_ url: URL, inApp: Bool) {

		var shouldOpenInApp = inApp
		if url.scheme == "tel" {
			// Do not open phone numbers in app, doesn't work & will crash.
			shouldOpenInApp = false
		}

		if shouldOpenInApp {
			let safariController = SFSafariViewController(url: url)

			if let presentedViewController = navigationController.presentedViewController {
				presentedViewController.presentingViewController?.dismiss(animated: true, completion: {
					self.navigationController.present(safariController, animated: true)
				})
			} else {
				navigationController.present(safariController, animated: true)
			}
		} else {
			UIApplication.shared.open(url)
		}
	}
}