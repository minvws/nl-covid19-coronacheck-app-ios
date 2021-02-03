/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {

	/// The user clicked on the next button
	/// - Parameter step: the current onboarding step
	func nextButtonClicked(step: OnboardingStep)
}

class OnboardingCoordinator: Coordinator, Logging {

	var loggingCategory: String = "OnboardingCoordinator"

	var coronaTestProof: CTRModel?

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// Initiatilzer
	init(navigationController: UINavigationController) {

		self.navigationController = navigationController
		onboardingInfos = factory.generate()
	}

	var onboardingInfos: [OnboardingInfo] = []

	var factory: OnboardingFactoryProtocol = OnboardingFactory()

	// Designated starter method
	func start() {

		if let info = onboardingInfos.first {
			addOnboardingStep(info)
		}
	}

	/*

	Thijs Weitkamp iPhone 
	*/

	/// Add an onboarding step
	/// - Parameter info: the info for the onboarding step
	func addOnboardingStep(_ info: OnboardingInfo) {

		let viewController = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: self,
				onboardingInfo: info,
				numberOfPages: onboardingInfos.count
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - OnboardingCoordinatorDelegate

extension OnboardingCoordinator: OnboardingCoordinatorDelegate {

	/// The user clicked on the next button
	/// - Parameter step: the current onboarding step
	func nextButtonClicked(step: OnboardingStep) {

		let rawValue = step.rawValue

		if rawValue < onboardingInfos.count {
			let info = onboardingInfos[rawValue + 1]
			addOnboardingStep(info)
		} else if rawValue == onboardingInfos.count {

			self.logInfo("Onboarding completed!")
		}
	}
}
