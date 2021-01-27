/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Sodium

class CTRModel {

	//	let eventIdentifier = "66f27d6a-b221-4e66-a3b4-8f199b2be116"
		let eventIdentifier = "d9ff36de-2357-4fa6-a64e-1569aa57bf1c"
	//	let eventIdentifier = "26820d8a-471e-4dc7-a38d-462b2baac5e0"
	//	let eventIdentifier = "904d864c-8e1b-499f-b9a1-d0debb1f5a6a"
	//	let eventIdentifier = "99285236-1847-4cdb-9c7d-4ac035282800"
	// let eventIdentifier = "ae7077dd-cf79-41e3-9248-9e71eb3e127e"
	//	let eventIdentifier = "3a381807-c564-4bad-960c-8eabf95d23fc"
	//	let eventIdentifier = "7d42af0f-9238-4289-812b-d9fec46b8c78"
	//	let eventIdentifier = "802d041c-f007-47e5-a48e-a221eb22137d"

	let userIdentifier = "ef9f409a-8613-4600-b135-8d2ac12559b3"
	//	let userIdentifier = "29b16f70-5f8a-49b4-a35f-5db253f5beab"
	//	let userIdentifier = "039072d7-875b-4928-a92e-b7d5b219d71a"
	//	let userIdentifier = "5e7a13ef-b037-42df-8a08-704d3e2a488a"

	var agentEnvelope: AgentEnvelope?

	var customerQR: CustomerQR?

	var issuers: [Issuer] = []

	var testResultEnvelope: TestResultEnvelope?

	var testResultForEvent: TestResult?

	var eventEnvelope: EventEnvelope?

	var apiClient: ApiClientProtocol = ApiClient()

	func populate() {

		fetchIssuers()
		fetchAgent()
//		getEvent()
	}

	func fetchIssuers() {

		apiClient.getPublicKeys { issuers in
			self.issuers = issuers
			self.getEvent()
		}
	}

	func fetchAgent() {

		apiClient.getAgentEnvelope(identifier: eventIdentifier) { envelope in
			self.agentEnvelope = envelope
		}
	}

	func getEvent() {

		apiClient.getEvent(identifier: eventIdentifier) { [self] envelope in
			self.eventEnvelope = envelope
		}
	}

	func checkEvent() {

		guard let testResultsEnvelope = testResultEnvelope,
			  let eventEnvelope = eventEnvelope else {
			print("CTR: error checking, no test results")
			return
		}

		var foundValidTest: TestResult?

		for validTestType in eventEnvelope.event.validTestsTypes {
			for userTest in testResultsEnvelope.testResults {

				// Same Test Type (PCR etc)
				if userTest.testType == validTestType.identifier {

					// Still Valid
					if let maxValidity = validTestType.maxValidity,
					   userTest.dateTaken + Int64(maxValidity) >= Int64(Date().timeIntervalSince1970) {

						print("CTR: Found a test for this event: \(validTestType.name), result was \(userTest.result)\n")
						// Replace or store
						if let existing = foundValidTest {

							if userTest.dateTaken >= existing.dateTaken {
								foundValidTest = userTest
							}

						} else {
							foundValidTest = userTest
						}
					} else {
						print("CTR: Test expired for this event")
					}
				} else {
					print("CTR: Test not for this event")
				}
			}
		}
		print("CTR: Check Event result: \(String(describing: foundValidTest))")
		testResultForEvent = foundValidTest
	}

	func validateCustomerQR() -> Bool {

		guard let agentEnvelope = agentEnvelope,
			  let customerQR = customerQR else {
			return false
		}

		// Unencrypted

		if let messageBytes = stringToBytes(base64EncodedInput: customerQR.payload),
		   let publicKeyBytes = stringToBytes(base64EncodedInput: customerQR.publicKey),
		   let secretKey = agentEnvelope.agent.event.privateKey,
		   let secretKeyBytes = stringToBytes(base64EncodedInput: secretKey),
		   let nonceBytes = stringToBytes(base64EncodedInput: customerQR.nonce) {

			let sodium = Sodium()

			if let unencryptedBytes = sodium.box.open(
				authenticatedCipherText: messageBytes,
				senderPublicKey: publicKeyBytes,
				recipientSecretKey: secretKeyBytes,
				nonce: nonceBytes
			) {

				let unencryptedData = Data(bytes: unencryptedBytes, count: unencryptedBytes.count)
				let unencryptedString = String(bytes: unencryptedBytes, encoding: .utf8)

				print("CTR: Decrypted: \(unencryptedString ?? "")")

				do {
					let payload = try JSONDecoder().decode(Payload.self, from: unencryptedData)
					if let result = payload.test?.result {
						return result == 0
					}

					return false
				} catch let error {
					print("CTR: error! \(error)")
					return false
				}
			}
		}

		return false
	}

	func generateCustomerQRString() -> String {

		guard let event = eventEnvelope?.event,
			  let eventIdentifier = event.identifier,
			  let testResultEnvelope = testResultEnvelope else {
			return ""
		}

		var signature: TestSignature?
		if let testResult = testResultForEvent {
			for candidate in testResultEnvelope.signatures where candidate.identifier == testResult.identifier {
				signature = candidate
			}
		}

		let payload = Payload(
			identifier: eventIdentifier,
			time: Int64(Date().timeIntervalSince1970),
			test: testResultForEvent,
			signature: signature?.signature
		)

		let payloadString = generateString(object: payload)
		print("CTR:  Unencrypted payload: \(payloadString)")

		let sodium = Sodium()

		if let nonceBytes = sodium.randomBytes.buf(length: 24),
		   let publicKey = event.publicKey,
		   let publicKeyBytes = stringToBytes(base64EncodedInput: publicKey),
		   let payloadBytes = stringToBytes(rawInput: payloadString),
		   let keyPair = sodium.box.keyPair() {

			let secretKeyBytes = keyPair.secretKey

			if let encryptedPayloadBytes = sodium.box.seal(
				message: payloadBytes,
				recipientPublicKey: publicKeyBytes,
				senderSecretKey: secretKeyBytes,
				nonce: nonceBytes) {

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
