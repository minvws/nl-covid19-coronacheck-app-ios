/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {

	/// Show the privacy page
	/// - Parameter viewController: the presenting viewcontroller
	func showPrivacyPage(_ viewController: UIViewController)

	/// Dismiss the presented viewcontroller
	func dismiss()

	/// The onboarding is finished
	func finishOnboarding()
}

protocol OnboardingDelegate: AnyObject {

	/// The onboarding is finished
	func finishOnboarding()
}

class OnboardingCoordinator: Coordinator, Logging {

	var loggingCategory: String = "OnboardingCoordinator"

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The onboarding delegate
	weak var onboardingDelegate: OnboardingDelegate?

	/// A presenting view controller
	weak var presentingViewController: UIViewController?

	/// Initiatilzer
	init(
		navigationController: UINavigationController,
		onboardingDelegate: OnboardingDelegate) {

		self.navigationController = navigationController
		self.onboardingDelegate = onboardingDelegate
		onboardingPages = factory.create()
	}

	/// The onboarding pages
	var onboardingPages: [OnboardingPage] = []

	/// The factory for onboarding pages
	var factory: OnboardingFactoryProtocol = OnboardingFactory()
	
	// Designated starter method
	func start() {

		let viewModel = OnboardingViewModel(
			coordinator: self,
			pages: onboardingPages
		)
		let viewController = OnboardingViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - OnboardingCoordinatorDelegate

extension OnboardingCoordinator: OnboardingCoordinatorDelegate {

	/// Show the privacy page
	/// - Parameter viewController: the presenting view controller
	func showPrivacyPage(_ viewController: UIViewController) {

		let viewModel = PrivacyViewModel(
			coordinator: self,
			title: .holderPrivacyTitle,
			message: .holderPrivacyMessage
		)
		let privacyViewController = PrivacyViewController(viewModel: viewModel)
		let navigationController = UINavigationController(rootViewController: privacyViewController)

		viewController.present(navigationController, animated: true, completion: nil)
		presentingViewController = viewController
	}

	func dismiss() {

		presentingViewController?.dismiss(animated: true, completion: nil)
		presentingViewController = nil
	}

	/// The onboarding is finished
	func finishOnboarding() {
		
		onboardingDelegate?.finishOnboarding()
	}
}
