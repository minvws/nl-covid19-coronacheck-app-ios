/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The resulting actions in this scene
enum ForcedInformationResult {

	/// The user gave consent
	case consentAgreed

	/// The user did not gave consent
	case consentNotAgreed

	/// The user viewed the content
	case consentViewed
}

protocol ForcedInformationCoordinatorDelegate: AnyObject {

	/// The user did finish the consent scene
	/// - Parameter result: the result of the scene
	func didFinishConsent(_ result: ForcedInformationResult)
}

protocol ForcedInformationDelegate: AnyObject {

	/// The forced infomration flow is finished
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

	/// Initiatilzer
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

	func start() {

		logInfo("Starting Forced Information Flow")
		let viewController = ForcedInformationViewController(
			viewModel: ForcedInformationViewModel(
				self,
				forcedInformationConsent: ForcedInformationConsent(
					title: .newTermsTitle,
					highlight: .newTermsHighlights,
					content: .newTermsDescription,
					mustGiveConsent: true
				)
			)
		)
		navigationController.viewControllers = [viewController]
	}
}

// MARK: - ForcedInformationCoordinatorDelegate

extension ForcedInformationCoordinator: ForcedInformationCoordinatorDelegate {

	/// The user did finish the consent scene
	/// - Parameter result: the result of the scene
	func didFinishConsent(_ result: ForcedInformationResult) {

		switch result {
			case .consentAgreed:
				logDebug("Consent was given")
				delegate?.finishForcedInformation()
			case .consentNotAgreed:
				logDebug("Consent was not given")
			case .consentViewed:
				logDebug("Consent was viewed")
				delegate?.finishForcedInformation()
		}
	}
}
