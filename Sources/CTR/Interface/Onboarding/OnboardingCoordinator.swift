/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

class OnboardingCoordinator: Coordinator {
	
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
	
	private var appFlavor: AppFlavor
	
	/// Initiatilzer
	init(
		navigationController: UINavigationController,
		onboardingDelegate: OnboardingDelegate,
		factory: OnboardingFactoryProtocol,
		appFlavor: AppFlavor = .flavor) {
		
		self.navigationController = navigationController
		self.onboardingDelegate = onboardingDelegate
		self.appFlavor = appFlavor
		onboardingFactory = factory
		onboardingPages = onboardingFactory.create()
	}
	
	/// The onboarding pages
	var onboardingPages: [PagedAnnoucementItem] = []
	
	// Designated starter method
	func start() {
		
		let viewModel = PagedAnnouncementViewModel(
			delegate: self,
			pages: onboardingPages,
			itemsShouldShowWithFullWidthHeaderImage: false,
			shouldShowWithVWSRibbon: true
		)
		let viewController = PagedAnnouncementViewController(
			viewModel: viewModel,
			allowsBackButton: true,
			allowsCloseButton: false,
			allowsNextButton: true
		)
		navigationController.viewControllers = [viewController]
		navigationController.view.window?.replaceRootViewController(with: navigationController)
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

// MARK: - PagedAnnouncementDelegate

extension OnboardingCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		if appFlavor == .holder {
			Current.disclosurePolicyManager.setDisclosurePolicyUpdateHasBeenSeen()
		}

		// Notify that we finished the onboarding
		onboardingDelegate?.finishOnboarding()

		// Go to consent
		let viewController = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
				coordinator: self,
				factory: onboardingFactory,
				shouldHideBackButton: false
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - OnboardingCoordinatorDelegate

extension OnboardingCoordinator: OnboardingCoordinatorDelegate {
	
	func showPrivacyPage() {

		let urlString: String

		if appFlavor == .holder {
			urlString = L.holderUrlPrivacy()
		} else {
			urlString = L.verifierUrlPrivacy()
		}

		guard let privacyUrl = URL(string: urlString) else {
			Current.logHandler.logError("No privacy url for \(urlString)")
			return
		}
		openUrl(privacyUrl, inApp: true)
	}

	/// Dismiss the presented viewController
	func dismiss() {
		
		presentingViewController?.dismiss(animated: true, completion: nil)
		presentingViewController = nil
	}

	/// Navigate to the consent page
	func navigateToConsent() {

		let viewController = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
				coordinator: self,
				factory: onboardingFactory,
				shouldHideBackButton: true
			)
		)
		navigationController.viewControllers = [viewController]
		navigationController.view.window?.replaceRootViewController(with: navigationController)
	}

	/// Consent was given
	func consentGiven() {

		onboardingDelegate?.consentGiven()
		navigationController.popToRootViewController(animated: false)
	}
}
