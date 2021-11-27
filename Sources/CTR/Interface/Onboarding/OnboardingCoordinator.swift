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
	func navigateToConsent(shouldHideBackButton: Bool)

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

    // MARK: - Universal Link handling

    /// Override point for coordinators which wish to deal with universal links.
    func consume(universalLink: UniversalLink) -> Bool {
        return false
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
			urlString = L.holderUrlPrivacy()
		} else {
			urlString = L.verifierUrlPrivacy()
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
		navigateToConsent(shouldHideBackButton: false)
	}

	/// Navigate to the consent page
	func navigateToConsent(shouldHideBackButton: Bool) {

		let viewController = OnboardingConsentViewController(
			viewModel: OnboardingConsentViewModel(
				coordinator: self,
				factory: onboardingFactory,
				shouldHideBackButton: shouldHideBackButton
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	/// Consent was given
	func consentGiven() {

		onboardingDelegate?.consentGiven()
		navigationController.popToRootViewController(animated: false)
	}
}
