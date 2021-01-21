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
			signature: signature?.signature
		)

		let payloadString = generateString(object: payload)
		print("CTR:  Unencrypted payload: \(payload)")

		let sodium = Sodium()

		let nonceBytes = sodium.randomBytes.buf(length: 24)!
		let nonceString = bytesToBase64String(nonceBytes)

		if let publicKey = event.publicKey,
		   let publicKeyBytes = stringToBytes(base64EncodedInput: publicKey),
		   let payloadBytes = stringToBytes(rawInput: payloadString),
		   let keyPair = sodium.box.keyPair() {

			let secretKeyBytes = keyPair.secretKey
			let secretKeyString = bytesToBase64String(secretKeyBytes)

			if let encryptedPayloadBytes = sodium.box.seal(
				message: payloadBytes,
				recipientPublicKey: publicKeyBytes,
				senderSecretKey: secretKeyBytes,
				nonce: nonceBytes) {


//
//			if let (encryptedPayloadBytes, nonceBytes) = sodium.box.seal(
//				message: payloadBytes,
//				recipientPublicKey: publicKeyBytes,
//				senderSecretKey: publicKeyBytes) {


//				let decr = sodium.box.open(authenticatedCipherText: encryptedPayloadBytes, senderPublicKey: keyPair.secretKey, recipientSecretKey: publicKeyBytes, nonce: nonceBytes)
//				let decryptedData = Data(bytes: decr!, count: decr!.count)
//				let decryptedString = String(bytes: decr!, encoding: .utf8)


//				print("CTR: Check DEcr: \(decryptedString ?? "")")

				let nonceString = bytesToBase64String(nonceBytes)

				let encryptedPayloadBase64String = bytesToBase64String(encryptedPayloadBytes)

				let customerQR = CustomerQR(
					publicKey: bytesToBase64String(keyPair.publicKey),
					nonce: nonceString,
					payload: encryptedPayloadBase64String
				)

				return generateString(object: customerQR)
			}
		}

		let customerQR = CustomerQR(
			publicKey: "x",
			nonce: "x",
			payload: payloadString
		)

		return generateString(object: customerQR)
	}

	func generateString<T>(object: T) -> String where T: Codable {

		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .utf8) {
			print("CTR: Converted to \(convertedToString)")
			return convertedToString
		}
		return ""
	}

	func bytesToBase64Data(_ input: [UInt8]) -> Data {

		return Data(bytes: input, count: input.count).base64EncodedData()
	}

	func bytesToBase64String(_ input: [UInt8]) -> String {

		return Data(bytes: input, count: input.count).base64EncodedString()
	}

	func stringToBytes(base64EncodedInput input: String) -> Bytes? {

		if let data = Data(base64Encoded: input) {
			return [UInt8](data)
		}
		return nil
	}

	func stringToBytes(rawInput input: String) -> Bytes? {

		if let data = input.data(using: .utf8) {
			return [UInt8](data)
		}
		return nil
	}
}
