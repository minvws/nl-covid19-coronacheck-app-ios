/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class CryptoManagerSpy: CryptoManaging {

	var setNonceCalled = false
	var setStokenCalled = false
	var setProofsCalled = false
	var nonce: String?
	var stoken: String?
	var proofs: Data?

	required init() {
		// Nothing for this spy class
	}

	func debug() {

	}

	func setNonce(_ nonce: String) {

		setNonceCalled = true
		self.nonce = nonce
	}
	
	func setStoken(_ stoken: String) {

		setStokenCalled = true
		self.stoken = stoken
	}

	func setTestProof(_ signatureMessage: Data?) {

		setProofsCalled = true
		self.proofs = signatureMessage
	}

	func reset() {
		// Nothing yet
	}

	func createCredential() {
		// Nothing yet
	}

	func generateCommitmentMessage() -> String? {
		return nil
	}

	func generateQRmessage() -> Data? {
		return nil
	}

	func getStoken() -> String? {
		return stoken
	}

	func verifyQRMessage(_ message: String) -> Attributes? {
		return nil
	}

	func readCredentials() -> CrypoAttributes? {
		return nil
	}
}
