/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol VerifierCoordinatorDelegate: AnyObject {

	/// Navigate to the Eventt Scene
	func navigateToEvent()

	/// Navigate to the Generate Event QR Scene
	func navigateToEventQR()

	// Navigate to the Customer Scan Scene
	func navigateToCustomerScan()

	// Navigate to the Test Result
	func navigateToTestResult()

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

class VerifierCoordinator: Coordinator {

	var event: Event = Event(
		title: "Awesome Event", location: "Ziggo Dome", time: "Vanavond")

	var testResult: TestResult?

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

		let viewController = VerifierStartViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {

	/// Navigate to the Eventt Scene
	func navigateToEvent() {

		let viewController = VerifierEventViewController()
		viewController.coordinator = self
		viewController.event = event
		navigationController.pushViewController(viewController, animated: true)
	}

	/// Navigate to the Generate Event QR Scene
	func navigateToEventQR() {

		let viewController = VerifierGenerateQRViewController()
		viewController.coordinator = self
		viewController.qrString = event.generateString()
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Customer Scan Scene
	func navigateToCustomerScan() {

		let viewController = VerifierScanViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Test Result
	func navigateToTestResult() {

		let viewController = VerifierResultViewController()
		viewController.coordinator = self
		viewController.testResult = testResult
		navigationController.pushViewController(viewController, animated: true)
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

	/// Navigate to the start fo the customer flow
	func navigateToStart() {

		guard navigationController.viewControllers.count > 1 else {
			return
		}
		navigationController.popToViewController(navigationController.viewControllers[1], animated: true)
	}

	/// Dismiss the viewcontroller
	func dismiss() {

		navigationController.popViewController(animated: true)
	}
}
