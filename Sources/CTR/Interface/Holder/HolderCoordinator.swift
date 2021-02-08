/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol HolderCoordinatorDelegate: AnyObject {

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults()

	// Navigate to the Generate Holder QR Scene
	func navigateToHolderQR()

	/// Navigate to the start fo the holder flow
	func navigateToStart()
}

class HolderCoordinator: Coordinator {

	/// The UI Window
	private var window: UIWindow

	var coronaTestProof: CTRModel?

	/// The side panel controller
	var sidePanelController: SidePanelController?

	/// The onboardings manager
	var onboardingManager: OnboardingManaging = Services.onboardingManager

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// Initiatilzer
	init(navigationController: UINavigationController, window: UIWindow) {

		self.navigationController = navigationController
		self.window = window
	}

	// Designated starter method
	func start() {

		if onboardingManager.needsOnboarding {

			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self
			)
			startChildCoordinator(coordinator)
		} else {

			navigateToHolderStart()
		}
	}
}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {

	func navigateToHolderStart() {

		let dashboardViewController = HolderStartViewController() // DashboardViewController()
		let menu = MenuViewController()

		let sidePanelController = CustomSidePanelController(sideController: menu)
		sidePanelController.selectedViewController = UINavigationController(rootViewController: dashboardViewController)

		// Replace the root with the side panel controller
		window.rootViewController = sidePanelController

//		let viewController = HolderStartViewController()
//		viewController.coordinator = self
//		navigationController.viewControllers = [viewController]
	}

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults() {

		let viewController = HolderFetchResultViewController(
			viewModel: FetchResultViewModel(
				coordinator: self,
				openIdClient: OpenIdClient(configuration: Configuration()),
				userIdentifier: coronaTestProof?.userIdentifier
			)
		)

		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Generate Holder QR Scene
	func navigateToHolderQR() {

		let viewController = HolderGenerateQRViewController(viewModel: GenerateQRViewModel(coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	/// Navigate to the start fo the holder flow
	func navigateToStart() {

		navigationController.popToRootViewController(animated: true)
	}
}

extension HolderCoordinator: OnboardingDelegate {

	/// The onboarding is finished
	func consentGiven() {

		// Mark as complete
		onboardingManager.finishOnboarding()

		// Remove child coordinator
		if let onboardingCoorinator = childCoordinators.first {
			removeChildCoordinator(onboardingCoorinator)
		}

		// Navigate to Holder Start.
		navigateToHolderStart()
	}
}
