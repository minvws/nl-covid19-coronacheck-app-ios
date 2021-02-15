/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol VerifierCoordinatorDelegate: AnyObject {

	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome()

	/// Navigate to the QR scanner
	func navigateToScan()

	/// Navigate to the scan result
	func navigateToScanResult()
}

class VerifierCoordinator: Coordinator, Logging {

	var loggingCategory: String = "VerifierCoordinator"

	/// The UI Window
	private var window: UIWindow

	/// The side panel controller
	var sidePanel: SidePanelController?

	/// The onboardings manager
	var onboardingManager: OnboardingManaging = Services.onboardingManager

	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = VerifierOnboardingFactory()

	/// The crypto manager
	var cryptoManager: CryptoManaging = Services.cryptoManager

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The dashboard navigation controller
	var dashboardNavigationContoller: UINavigationController?

	/// Initiatilzer
	init(navigationController: UINavigationController, window: UIWindow) {

		self.navigationController = navigationController
		self.window = window
	}

	// Designated starter method
	func start() {

		if onboardingManager.needsOnboarding {
			/// Start with the onboarding
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory
			)
			startChildCoordinator(coordinator)

		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent()
		} else {

			navigateToVerifierWelcome()
		}
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {

	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome() {

		let menu = MenuViewController(
			viewModel: MenuViewModel(
				delegate: self
			)
		)
		sidePanel = CustomSidePanelController(sideController: UINavigationController(rootViewController: menu))

		let dashboardViewController = VerifierStartViewController()
		dashboardViewController.coordinator = self

		//		let dashboardViewController = HolderDashboardViewController(
		//			viewModel: HolderDashboardViewModel(
		//				coordinator: self,
		//				cryptoManager: cryptoManager,
		//				proofManager: proofManager,
		//				configuration: generalConfiguration
		//			)
		//		)
		dashboardNavigationContoller = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationContoller

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel
	}

	/// Navigate to the QR scanner
	func navigateToScan() {

		navigateToScanResult()

//		let destination = VerifierScanViewController(
//			viewModel: VerifierScanViewModel(
//				coordinator: self,
//				cryptoManager: cryptoManager
//			)
//		)
//
//		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to the scan result
	func navigateToScanResult() {

		let viewController = VerifierResultViewController(
			viewModel: VerifierResultViewModel(
				delegate: self
			)
		)
		let destination = UINavigationController(rootViewController: viewController)
		sidePanel?.selectedViewController?.present(destination, animated: true, completion: nil)
	}
}

// MARK: - Dismissable

extension VerifierCoordinator: Dismissable {

	func dismiss() {

		sidePanel?.selectedViewController?.dismiss(animated: true, completion: nil)
	}
}

// MARK: - MenuDelegate

extension VerifierCoordinator: MenuDelegate {

	/// Close the menu
	func closeMenu() {

		sidePanel?.hideSidePanel()
	}

	/// Open a menu item
	/// - Parameter identifier: the menu identifier
	func openMenuItem(_ identifier: MenuIdentifier) {

		switch identifier {
			case .overview:
				dashboardNavigationContoller?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationContoller
			default:
				self.logInfo("User tapped on \(identifier), not implemented")

				let destinationViewController = PlaceholderViewController()
				destinationViewController.placeholder = "\(identifier)"
				let navigationController = UINavigationController(rootViewController: destinationViewController)
				sidePanel?.selectedViewController = navigationController
		}
	}

	/// Get the items for the top menu
	/// - Returns: the top menu items
	func getTopMenuItems() -> [MenuItem] {

		return [
			MenuItem(identifier: .overview, title: .verifierMenuDashboard),
			MenuItem(identifier: .support, title: .verifierMenuSupport)
		]
	}
	/// Get the items for the bottom menu
	/// - Returns: the bottom menu items
	func getBottomMenuItems() -> [MenuItem] {

		return [
			MenuItem(identifier: .about, title: .verifierMenuAbout),
			MenuItem(identifier: .feedback, title: .verifierMenuFeedback)
		]
	}
}

// MARK: - OnboardingDelegate

extension VerifierCoordinator: OnboardingDelegate {

	/// User has seen all the onboarding pages
	func finishOnboarding() {

		onboardingManager.finishOnboarding()
	}

	/// The onboarding is finished
	func consentGiven() {

		// Mark as complete
		onboardingManager.consentGiven()

		// Remove child coordinator
		if let onboardingCoorinator = childCoordinators.first {
			removeChildCoordinator(onboardingCoorinator)
		}

		// Navigate to Verifier Welcome.
		navigateToVerifierWelcome()
	}
}
