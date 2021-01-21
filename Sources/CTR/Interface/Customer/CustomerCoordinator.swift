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

	/// Set the test result
	/// - Parameter result: the test result
	func setTestResult(_ result: TestResult?)

	/// Set the event
	/// - Parameter event: the event
	func setEvent(_ event: Event)

	/// Dismiss the viewcontroller
	func dismiss()
}

class CustomerCoordinator: Coordinator {

	var userIdentifier = "ef9f409a-8613-4600-b135-8d2ac12559b3"

	var issuers: [Issuer] = []

	var testResultEnvelope: TestResultEnvelope?

	var testResultForEvent: TestResult?

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

		APIClient().getIssuers { issuers in
			self.issuers = issuers
		}

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
		viewController.userIdentifier = userIdentifier
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Visit Event Scene
	func navigateToVisitEvent() {

		let viewController = CustomerScanViewController()
		viewController.coordinator = self
		viewController.issuers = issuers
		viewController.testResults = testResultEnvelope
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Generate Customer QR Scene
	func navigateToCustomerQR() {

		let viewController = CustomerGenerateQRViewController()
		viewController.coordinator = self
		viewController.qrString = generateCustomerQRString()
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

		self.testResultEnvelope = result
	}

	/// Set the event
	/// - Parameter event: the event
	func setEvent(_ event: Event) {

		self.event = event
	}

	/// Set the test result
	/// - Parameter result: the test result
	func setTestResult(_ result: TestResult?) {
		self.testResultForEvent = result
	}

	/// Dismiss the viewcontroller
	func dismiss() {

		navigationController.popViewController(animated: true)
	}
}

/*

struct Payload: Codable {
var identifier: String
var time: Int64
var test: String?
var signature: String?
}

struct CustomerQR: Codable {

var publicKey: String
var nonce: String
var payload: String
}
*/

import Sodium

extension CustomerCoordinator {

	func generateCustomerQRString() -> String {

		guard let event = event,
			  let eventIdentifier = event.identifier,
			  let testResultForEvent = testResultForEvent,
			  let testResultEnvelope = testResultEnvelope else {
			return ""
		}

		var signature: TestSignature?
		for candidate in testResultEnvelope.signatures where candidate.identifier == testResultForEvent.identifier {
			signature = candidate
		}

		let payload = Payload(
			identifier: eventIdentifier,
			time: Int64(Date().timeIntervalSince1970),
			test: testResultForEvent,
			signature: signature
		)

		let payloadString = generateString(object: payload)
		print("CTR:  Unencrypted payload: \(payload)")

//		let sodium = Sodium()
//
//		guard let citizenEvenKeyPair = sodium.box.keyPair() else {
//			return ""
//		}
//
//		let nonce = sodium.randomBytes.random()

		let customerQR = CustomerQR(
			publicKey: "x",
			nonce: "x",
			payload: payloadString
		)

		return generateString(object: customerQR)
	}

	func generateString<T>(object: T) -> String where T: Codable {

		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .ascii) {
			print("CTR: Converted to \(convertedToString)")
			return convertedToString
		}
		return ""
	}
}
