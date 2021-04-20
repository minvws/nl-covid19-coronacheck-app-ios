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
	/// - Parameters:
	///   - url: The url to open
	///   - inApp: True if we should open the url in a in-app browser, False if we want the OS to handle the url
	func openUrl(_ url: URL, inApp: Bool)
}

/// The shared base class for the holder and verifier coordinator.
class SharedCoordinator: Coordinator, Logging {

	var loggingCategory: String = "SharedCoordinator"

	var window: UIWindow

	/// The side panel controller that holds both the menu and the main view
	var sidePanel: SidePanelController?

	var onboardingManager: OnboardingManaging = Services.onboardingManager
	var forcedInformationManager: ForcedInformationManaging = Services.forcedInformationManager
	var cryptoManager: CryptoManaging = Services.cryptoManager
	var generalConfiguration: ConfigurationGeneralProtocol = Configuration()
	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	var proofManager: ProofManaging = Services.proofManager
	var versionSupplier = AppVersionSupplier()
	var childCoordinators: [Coordinator] = []

	// Navigation controllers for each of the flows from the menu
	var navigationController: UINavigationController
	var dashboardNavigationContoller: UINavigationController?
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
