/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol CustomerCoordinatorDelegate: AnyObject {

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults()

	/// Navigate to the Visit Event Scene
	func navigateToVisitEvent()

	// Navigate to the Generate Customer QR Scene
	func navigateToCustomerQR()

	/// Navigate to the start fo the customer flow
	func navigateToStart()

	/// Set the test result
	/// - Parameter result: the test result
	func setTestResult(_ result: TestResult)

	/// Set the event
	/// - Parameter event: the event
	func setEvent(_ event: Event)

	/// Dismiss the viewcontroller
	func dismiss()
}

class CustomerCoordinator: Coordinator {

	var testResult: TestResult = TestResult(status: .unknown, timeStamp: nil)

	var event: Event?

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// Initiatilzer
	init(navigationController: UINavigationController) {

		self.navigationController = navigationController
	}

	// Designated starter method
	func start() {

		let viewController = CustomerStartViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - CustomerCoordinatorDelegate

extension CustomerCoordinator: CustomerCoordinatorDelegate {

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults() {

		let viewController = CustomerFetchResultViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Visit Event Scene
	func navigateToVisitEvent() {

		let viewController = CustomerScanViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Generate Customer QR Scene
	func navigateToCustomerQR() {

		let viewController = CustomerGenerateQRViewController()
		viewController.coordinator = self
		viewController.qrString = testResult.generateString()
		navigationController.pushViewController(viewController, animated: true)
	}
	
	/// Navigate to the start fo the customer flow
	func navigateToStart() {

		guard navigationController.viewControllers.count > 1 else {
			return
		}
		navigationController.popToViewController(navigationController.viewControllers[1], animated: true)
	}

	/// Set the test result
	/// - Parameter result: the test result
	func setTestResult(_ result: TestResult) {

		self.testResult = result
	}

	/// Set the event
	/// - Parameter event: the event
	func setEvent(_ event: Event) {

		self.event = event
	}

	/// Dismiss the viewcontroller
	func dismiss() {

		navigationController.popViewController(animated: true)
	}
}
