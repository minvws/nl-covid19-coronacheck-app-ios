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

	/// Navigate to the consent page
	func navigateToConsent()

	/// Consent was given
	func consentGiven()
}

protocol OnboardingDelegate: AnyObject {

	/// The onboarding is finished
	func finishOnboarding()
	
	/// The consent is given
	func consentGiven()
}

class OnboardingCoordinator: Coordinator, Logging {
	
	var loggingCategory: String = "OnboardingCoordinator"
	
	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []
	
	/// The navigation controller
	var navigationController: UINavigationController
	
	/// The onboarding delegate
	weak var onboardingDelegate: OnboardingDelegate?

	var onboardingFactory: OnboardingFactoryProtocol
	
	/// A presenting view controller
	weak var presentingViewController: UIViewController?
	
	/// Initiatilzer
	init(
		navigationController: UINavigationController,
		onboardingDelegate: OnboardingDelegate,
		factory: OnboardingFactoryProtocol) {
		
		self.navigationController = navigationController
		self.onboardingDelegate = onboardingDelegate
		onboardingFactory = factory
		onboardingPages = onboardingFactory.create()
	}
	
	/// The onboarding pages
	var onboardingPages: [OnboardingPage] = []
	
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
			title: onboardingFactory.getPrivacyTitle(),
			message: onboardingFactory.getPrivacyMessage()
		)
		let privacyViewController = PrivacyViewController(viewModel: viewModel)
		let navigationController = UINavigationController(rootViewController: privacyViewController)
		
		viewController.present(navigationController, animated: true, completion: nil)
		presentingViewController = viewController
	}

	/// Dismiss the presented viewcontroller
	func dismiss() {
		
		presentingViewController?.dismiss(animated: true, completion: nil)
		presentingViewController = nil
	}
	
	/// The onboarding is finished
	func finishOnboarding() {

		// Notify that we finished the onboarding
		onboardingDelegate?.finishOnboarding()

		// Go to consent
		navigateToConsent()
	}

	/// Navigate to the consent page
	func navigateToConsent() {

		let viewController = ConsentViewController(
			viewModel: ConsentViewModel(
				coordinator: self,
				factory: onboardingFactory
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	/// Consent was given
	func consentGiven() {

		onboardingDelegate?.consentGiven()
	}
}
