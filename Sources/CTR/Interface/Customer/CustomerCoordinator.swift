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
	func setTestResultEnvelope(_ result: TestResultEnvelope?)

//	/// Set the test result
//	/// - Parameter result: the test result
//	func setTestResult(_ result: TestResult?)

	/// Set the event
	/// - Parameter event: the event
	func setEvent(_ event: EventEnvelope)

	/// Dismiss the viewcontroller
	func dismiss()
}

class CustomerCoordinator: Coordinator {

	var coronaTestProof: CTRModel?

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
		viewController.userIdentifier = coronaTestProof?.userIdentifier
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Visit Event Scene
	func navigateToVisitEvent() {

		let viewController = CustomerScanViewController()
		viewController.coordinator = self
		viewController.issuers = coronaTestProof?.issuers ?? []
		viewController.testResults = coronaTestProof?.testResultEnvelope
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Generate Customer QR Scene
	func navigateToCustomerQR() {

		let viewController = CustomerGenerateQRViewController()
		viewController.coordinator = self
		viewController.qrString = coronaTestProof?.generateCustomerQRString() ?? ""
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
	func setTestResultEnvelope(_ result: TestResultEnvelope?) {

		coronaTestProof?.testResultEnvelope = result
		coronaTestProof?.checkEvent()
	}

	/// Set the event
	/// - Parameter event: the event
	func setEvent(_ event: EventEnvelope) {

		coronaTestProof?.eventEnvelope = event
	}

//	/// Set the test result
//	/// - Parameter result: the test result
//	func setTestResult(_ result: TestResult?) {
//
//		coronaTestProof?.testResultForEvent = result
//	}

	/// Dismiss the viewcontroller
	func dismiss() {

		navigationController.popViewController(animated: true)
	}
}
