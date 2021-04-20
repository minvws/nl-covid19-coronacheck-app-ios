/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol OnboardingCoordinatorDelegate: AnyObject {

	func showPrivacyPage()
	
	/// Dismiss the presented viewController
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

	/// The onboarding factory
	var onboardingFactory: OnboardingFactoryProtocol

	/// The general configuration
	var generalConfiguration: ConfigurationGeneralProtocol = Configuration()
	
	/// A presenting view controller
	weak var presentingViewController: UIViewController?
	
	/// Initiatilzer
	init(
		navigationController: UINavigationController,
		onboardingDelegate: OnboardingDelegate,
		factory: OnboardingFactoryProtocol,
		maxValidity: String) {
		
		self.navigationController = navigationController
		self.onboardingDelegate = onboardingDelegate
		onboardingFactory = factory
		onboardingPages = onboardingFactory.create(maxValidity: maxValidity)
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

// MARK: - OpenUrlProtocol

extension OnboardingCoordinator: OpenUrlProtocol {

	/// Open a url
	func openUrl(_ url: URL, inApp: Bool) {

		if inApp {
			let safariController = SFSafariViewController(url: url)
			navigationController.present(safariController, animated: true)
		} else {
			UIApplication.shared.open(url)
		}
	}
}

// MARK: - OnboardingCoordinatorDelegate

extension OnboardingCoordinator: OnboardingCoordinatorDelegate {
	
	func showPrivacyPage() {

		let urlString: String

		if AppFlavor.flavor == .holder {
			urlString = .holderUrlPrivacy
		} else {
			urlString = .verifierUrlPrivacy
		}

		guard let privacyUrl = URL(string: urlString) else {
			logError("No privacy url for \(urlString)")
			return
		}
		openUrl(privacyUrl, inApp: true)
	}

	/// Dismiss the presented viewController
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
