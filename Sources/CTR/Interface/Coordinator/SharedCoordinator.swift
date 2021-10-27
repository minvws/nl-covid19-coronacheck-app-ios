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

protocol Restartable: AnyObject {

	func restart()
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
	var versionSupplier = AppVersionSupplier()
	var childCoordinators: [Coordinator] = []

	// Navigation controllers for each of the flows from the menu
	var navigationController: UINavigationController
	var dashboardNavigationController: UINavigationController?
	var aboutNavigationController: UINavigationController?

	/// Initiatilzer
	init(navigationController: UINavigationController, window: UIWindow) {

		self.navigationController = navigationController
		self.window = window
	}

	// Designated starter method
	func start() {

		// To be overwritten
	}

	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool = true) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: openURLsInApp)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		presentAsBottomSheet(viewController)
	}

	func presentAsBottomSheet(_ viewController: UIViewController) {

		(sidePanel?.selectedViewController as? UINavigationController)?.visibleViewController?.presentBottomSheet(viewController)
	}

    // MARK: - Universal Link handling

    /// Override point for coordinators which wish to deal with universal links.
    func consume(universalLink: UniversalLink) -> Bool {
        return false
    }
}

// MARK: - Shared

extension SharedCoordinator {

	/// Handle the onboarding
	/// - Parameters:
	///   - factory: the onboarding factory for the content
	///   - onCompletion: the completion handler when onboarding is done
	func handleOnboarding(factory: OnboardingFactoryProtocol, onCompletion: () -> Void) {

		if onboardingManager.needsOnboarding {
			/// Start with the onboarding
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: factory
			)
			startChildCoordinator(coordinator)
			return

		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: factory
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent(shouldHideBackButton: true)
			return

		}
		onCompletion()
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

			if let presentedViewController = sidePanel?.selectedViewController?.presentedViewController {
				presentedViewController.presentingViewController?.dismiss(animated: true, completion: {
					self.sidePanel?.selectedViewController?.present(safariController, animated: true)
				})
			} else {
				sidePanel?.selectedViewController?.present(safariController, animated: true)
			}
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
		// Also mark as complete for forced information
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

// MARK: - Restartable

extension SharedCoordinator: Restartable {

	/// Restart the app
	func restart() {

		if #available(iOS 13.0, *) {
			// Use Scene lifecycle
			if let scene = UIApplication.shared.connectedScenes.first,
				let sceneDelegate: SceneDelegate = (scene.delegate as? SceneDelegate) {
				sceneDelegate.appCoordinator?.retry()
			}
		} else {
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				appDelegate.appCoordinator?.retry()
			}
		}
	}
}
