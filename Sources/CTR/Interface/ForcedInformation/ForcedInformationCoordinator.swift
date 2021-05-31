/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

/// The resulting actions in this scene
enum ForcedInformationResult {

	/// The user gave consent
	case consentAgreed

	/// The user viewed the content
	case consentViewed
}

protocol ForcedInformationCoordinatorDelegate: AnyObject {

	/// The user did finish the consent scene
	/// - Parameter result: the result of the scene
	func didFinishConsent(_ result: ForcedInformationResult)
}

protocol ForcedInformationDelegate: AnyObject {

	/// The forced information flow is finished
	func finishForcedInformation()
}

class ForcedInformationCoordinator: Coordinator, Logging {

	/// The category for logging
	var loggingCategory: String = "ForcedInformationCoordinator"

	/// The child coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The forced information manager
	var forcedInformationManager: ForcedInformationManaging

	/// The forced information delegate
	weak var delegate: ForcedInformationDelegate?

	/// Initiailzer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - forcedInformationManager: the forced information manager
	///   - delegate: the forced information delegate
	init(
		navigationController: UINavigationController,
		forcedInformationManager: ForcedInformationManaging,
		delegate: ForcedInformationDelegate) {

		self.navigationController = navigationController
		self.forcedInformationManager = forcedInformationManager
		self.delegate = delegate
	}

	/// Start the scene
	func start() {

		logInfo("Starting Forced Information Flow")
		
		if let forcedInformationPage = forcedInformationManager.getUpdatePage() {
			
			let viewController = ForcedInformationViewController(
				viewModel: ForcedInformationViewModel(
					coordinator: self,
					pages: [forcedInformationPage]))
			navigationController.viewControllers = [viewController]
		} else {

			// no update required
			delegate?.finishForcedInformation()
		}
	}

    // MARK: - Universal Link handling

    /// Override point for coordinators which wish to deal with universal links.
    func consume(universalLink: UniversalLink) -> Bool {
        return false
    }
}

// MARK: - ForcedInformationCoordinatorDelegate & OpenUrlProtocol

extension ForcedInformationCoordinator: ForcedInformationCoordinatorDelegate, OpenUrlProtocol {

	/// The user did finish the consent scene
	/// - Parameter result: the result of the scene
	func didFinishConsent(_ result: ForcedInformationResult) {

		switch result {
			case .consentAgreed:
				logInfo("ForcedInformationCoordinator: Consent was given")
				forcedInformationManager.consentGiven()
				delegate?.finishForcedInformation()

			case .consentViewed:
				logInfo("ForcedInformationCoordinator: Consent was viewed")
				forcedInformationManager.consentGiven()
				delegate?.finishForcedInformation()
		}
	}

	/// Open a url
	/// - Parameters:
	///   - url: The url to open
	///   - inApp: True if we should open the url in a in-app browser, False if we want the OS to handle the url
	func openUrl(_ url: URL, inApp: Bool) {

		if inApp {
			let safariController = SFSafariViewController(url: url)
			navigationController.present(safariController, animated: true)
		} else {
			UIApplication.shared.open(url)
		}
	}
}
