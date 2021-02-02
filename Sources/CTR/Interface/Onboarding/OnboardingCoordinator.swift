/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {

}

class OnboardingCoordinator: Coordinator {

	var coronaTestProof: CTRModel?

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// Initiatilzer
	init(navigationController: UINavigationController) {

		self.navigationController = navigationController
	}

	var currentStep: OnboardingStep = .safelyOnTheRoad

	var onboardingInfo: [OnboardingInfo] = []

	var factory: OnboardingFactoryProtocol = OnboardingFactory()

	// Designated starter method
	func start() {

		onboardingInfo = factory.generate()

		let info = onboardingInfo[currentStep.rawValue]

		let viewController = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: self,
				onboardingInfo: info
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - OnboardingCoordinatorDelegate

extension OnboardingCoordinator: OnboardingCoordinatorDelegate {

}
