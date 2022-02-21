/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

/// The resulting actions in this scene
enum NewFeaturesScreenResult {
	
	/// The user viewed the update page
	case updateItemViewed

	/// The user gave consent
	case consentAgreed

	/// The user viewed the content
	case consentViewed
}

protocol NewFeaturesCoordinatorDelegate: AnyObject {

	/// The user did finish the consent scene
	/// - Parameter result: the result of the scene
	func didFinish(_ result: NewFeaturesScreenResult)
}

protocol NewFeaturesDelegate: AnyObject {

	/// The new feature information flow is finished
	func finishNewFeatures()
}

class NewFeaturesCoordinator: Coordinator, Logging {

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

		logVerbose("Starting New Features Information Flow")
		
		if let newFeatureItem = newFeaturesManager.getNewFeatureItem() {
			
			let viewController = NewFeaturesViewController(
				viewModel: NewFeaturesViewModel(
					coordinator: self,
					pages: [newFeatureItem]))
			navigationController.viewControllers = [viewController]
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

// MARK: - NewFeaturesCoordinatorDelegate & OpenUrlProtocol

extension NewFeaturesCoordinator: NewFeaturesCoordinatorDelegate, OpenUrlProtocol {

	/// The user did finish the consent scene
	/// - Parameter result: the result of the scene
	func didFinish(_ result: NewFeaturesScreenResult) {

		switch result {
			case .updateItemViewed:
				logVerbose("NewFeaturesCoordinator: Update page was viewed")
				
			case .consentAgreed:
				logVerbose("NewFeaturesCoordinator: Consent was given")

			case .consentViewed:
				logVerbose("NewFeaturesCoordinator: Consent was viewed")
		}
		
		newFeaturesManager.consentGiven()
		delegate?.finishNewFeatures()
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
