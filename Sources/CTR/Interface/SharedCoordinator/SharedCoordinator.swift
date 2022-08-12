/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
class SharedCoordinator: Coordinator {

	var window: UIWindow

	var onboardingManager: OnboardingManaging = Current.onboardingManager
	var newFeaturesManager: NewFeaturesManaging = Current.newFeaturesManager
	var remoteConfigManager: RemoteConfigManaging = Current.remoteConfigManager
	var versionSupplier = AppVersionSupplier()
	var childCoordinators: [Coordinator] = []

	// Navigation controllers for each of the flows from the menu
	let navigationController: UINavigationController

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

		let viewController = BottomSheetContentViewController(
			viewModel: BottomSheetContentViewModel(
				content: Content(
					title: title,
					body: body
				),
 				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: openURLsInApp)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		presentAsBottomSheet(viewController)
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
	///   - onboardingFactory: the onboarding factory for the content
	///   - newFeaturesFactory: the new features factory to display updated content
	///   - onCompletion: the completion handler when onboarding is done
	func handleOnboarding(onboardingFactory: OnboardingFactoryProtocol, newFeaturesFactory: NewFeaturesFactory, onCompletion: () -> Void) {
		
		newFeaturesManager.factory = newFeaturesFactory

		if onboardingManager.needsOnboarding {
			/// Start with the onboarding
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory
			)
			startChildCoordinator(coordinator)
			return

		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent()
			return

		} else if newFeaturesManager.needsUpdating {
			// Show new features
			   let coordinator = NewFeaturesCoordinator(
				   navigationController: navigationController,
				   newFeaturesManager: newFeaturesManager,
				   delegate: self
			   )
			   startChildCoordinator(coordinator)
			return
		}
		onCompletion()
	}
}

// MARK: - Dismissable

extension SharedCoordinator: Dismissable {

	func dismiss() {

		if navigationController.presentedViewController != nil {
			navigationController.dismiss(animated: true, completion: nil)
		} else {
			navigationController.popViewController(animated: false)
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
		if url.scheme == "tel" || url.scheme == "itms-apps" {
			// Do not open phone numbers or appstore links in app, doesn't work & will crash.
			shouldOpenInApp = false
		}

		guard #available(iOS 13.0, *), shouldOpenInApp else {
			UIApplication.shared.open(url)
			return
		}
		
		let safariController = SFSafariViewController(url: url)

		if let presentedViewController = navigationController.presentedViewController {
			presentedViewController.presentingViewController?.dismiss(animated: true) {
				self.navigationController.present(safariController, animated: true)
			}
		} else {
			navigationController.present(safariController, animated: true)
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
		
		// Preemtively mark the "new features" as seen too, so that the user doesn't see a modal after the onboarding:
		newFeaturesManager.userHasViewedNewFeatureIntro()
		
		// Remove child coordinator
		if let onboardingCoorinator = childCoordinators.first {
			removeChildCoordinator(onboardingCoorinator)
		}

		// Navigate to start
		start()
	}
}

// MARK: - NewFeaturesDelegate

extension SharedCoordinator: NewFeaturesDelegate {

	/// The user finished the new features
	func finishNewFeatures() {

		newFeaturesManager.userHasViewedNewFeatureIntro()
		
		// Remove childCoordinator
		if let newFeaturesCoordinator = childCoordinators.first {
			removeChildCoordinator(newFeaturesCoordinator)
		}
		
		// Navigate to start
		start()
	}
}

extension SharedCoordinator {

	/// Restart the app
	func restart() {

		if #available(iOS 13.0, *) {
			// Use Scene lifecycle
			if let scene = UIApplication.shared.connectedScenes.first,
				let sceneDelegate: SceneDelegate = (scene.delegate as? SceneDelegate) {
				sceneDelegate.appCoordinator?.reset()
			}
		} else {
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				appDelegate.appCoordinator?.reset()
			}
		}
	}
}
