/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices
import Shared
import Models
import Managers

protocol OnboardingCoordinatorDelegate: AnyObject {

	/// Consent was given
	func consentGiven()
}

protocol OnboardingDelegate: AnyObject {

	/// The onboarding is finished
	func finishOnboarding()
	
	/// The consent is given
	func consentGiven()
}

class OnboardingCoordinator: Coordinator, OpenUrlProtocol {
	
	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []
	
	/// The navigation controller
	var navigationController: UINavigationController
	
	/// The onboarding delegate
	weak var onboardingDelegate: OnboardingDelegate?

	/// The onboarding factory
	var onboardingFactory: OnboardingFactoryProtocol
	
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
			allowsPreviousPageButton: true,
			allowsCloseButton: false,
			allowsNextPageButton: true
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
