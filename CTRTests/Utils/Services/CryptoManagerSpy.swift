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
	var setIssuerPublicKeysCalled = false
	var issuerPublicKeysAreValid = true
	var hasPublicKeysCalled = false
	var keys: [IssuerPublicKey] = []
	var nonce: String?
	var stoken: String?
	var proofs: Data?

	var readCredentialCalled = false
	var crypoAttributes: CryptoAttributes?
	var removeCredentialCalled = false

	var generateQRmessageCalled = false
	var qrMessage: Data?

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

	func setIssuerPublicKeys(_ keys: [IssuerPublicKey]) -> Bool {

		setIssuerPublicKeysCalled = true
		if issuerPublicKeysAreValid {
			self.keys = keys
		}
		return issuerPublicKeysAreValid
	}

	func hasPublicKeys() -> Bool {

		hasPublicKeysCalled = true
		return !keys.isEmpty
	}

	func generateCommitmentMessage() -> String? {
		return nil
	}

	func generateQRmessage() -> Data? {

		generateQRmessageCalled = true
		return qrMessage
	}

	func getStoken() -> String? {
		return stoken
	}

	func verifyQRMessage(_ message: String) -> CryptoResult {
		return CryptoResult(nil, nil)
	}

	func removeCredential() {

		crypoAttributes = nil
		removeCredentialCalled = true
	}

	func createCredential(_ ism: Data) -> Result<Data, CryptoError> {

		return .failure(.unknown)
	}

	func readCredential() -> CryptoAttributes? {

		readCredentialCalled = true

		return crypoAttributes
	}

	func storeCredential(_ credential: Data) {
		// Nothing yet
	}
}
