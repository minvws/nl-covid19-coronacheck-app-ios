/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol Dismissable: AnyObject {

	/// Dismiss the presented viewcontroller
	func dismiss()
}

protocol OpenUrlProtocol: AnyObject {

	/// Open a url
	func openUrl(_ url: URL, inApp: Bool)
}

class SharedCoordinator: Coordinator, Logging {

	var loggingCategory: String = "SharedCoordinator"

	/// The UI Window
	var window: UIWindow

	/// The side panel controller
	var sidePanel: SidePanelController?

	/// The onboardings manager
	var onboardingManager: OnboardingManaging = Services.onboardingManager

	/// The forced information manager
	var forcedInformationManager: ForcedInformationManaging = Services.forcedInformationManager

	/// The crypto manager
	var cryptoManager: CryptoManaging = Services.cryptoManager

	/// The general configuration
	var generalConfiguration: ConfigurationGeneralProtocol = Configuration()

	/// The remote config manager
	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager

	/// The version supplier
	var versionSupplier = AppVersionSupplier()

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The dashboard navigation controller
	var dashboardNavigationContoller: UINavigationController?

	/// The about navigation controller
	var aboutNavigationContoller: UINavigationController?

	var maxValidity: Int {
		remoteConfigManager.getConfiguration().maxValidityHours ?? 40
	}

	/// Initiatilzer
	init(navigationController: UINavigationController, window: UIWindow) {

		self.navigationController = navigationController
		self.window = window
	}

	// Designated starter method
	func start() {

		// To be overwritten
	}
}

// MARK: - Dismissable

extension SharedCoordinator: Dismissable {

	func dismiss() {

		if sidePanel?.selectedViewController?.presentedViewController != nil {
			sidePanel?.selectedViewController?.dismiss(animated: true, completion: nil)
		} else {
			(sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: false)
		}
	}
}

// MARK: - OpenUrlProtocol

extension SharedCoordinator: OpenUrlProtocol {

	/// Open a url
	func openUrl(_ url: URL, inApp: Bool) {

		if inApp {
			let safariController = SFSafariViewController(url: url)
			sidePanel?.selectedViewController?.present(safariController, animated: true)
		} else {
			UIApplication.shared.open(url)
		}
	}
}

// MARK: - OnboardingDelegate

extension SharedCoordinator: OnboardingDelegate {

	/// User has seen all the onboarding pages
	func finishOnboarding() {

		onboardingManager.finishOnboarding()
	}

	/// The onboarding is finished
	func consentGiven() {

		// Mark as complete
		onboardingManager.consentGiven()
		// Also mark as complet for forced information
		forcedInformationManager.consentGiven()

		// Remove child coordinator
		if let onboardingCoorinator = childCoordinators.first {
			removeChildCoordinator(onboardingCoorinator)
		}

		// Navigate to start
		start()
	}
}

// MARK: - ForcedInformationDelegate

extension SharedCoordinator: ForcedInformationDelegate {

	/// The user finished the forced information
	func finishForcedInformation() {

		logDebug("SharedCoordinator: finishForcedInformation")

		// Remove childCoordinator
		if let forcedInformationCoordinator = childCoordinators.first {
			removeChildCoordinator(forcedInformationCoordinator)
		}

		// Navigate to start
		start()
	}
}
