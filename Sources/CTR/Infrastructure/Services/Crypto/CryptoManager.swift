/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Sodium
import Ctcl

struct NonceEnvelope: Codable {

	let nonce: String
	let stoken: String
}

protocol CryptoManagerProtocol {

	init()

	func debug()

	/// Set the nonce
	/// - Parameter nonce: the nonce
	func setNonce(_ nonce: String)

	/// set the stoken
	/// - Parameter stoken: the stoken
	func setStoken(_ stoken: String)

	/// Set the proofs
	/// - Parameter proofs: the test proofs
	func setProofs(_ proofs: Data?)

	/// Generate the commitment message
	/// - Returns: commitment message
	func generateCommitmentMessage() -> String?

	/// Generate a qr message
	/// - Returns: qr message
	func generateQRmessage() -> String?

	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String?

	func verifyQRMessage(_ message: String) -> Bool
}

/// The cryptography manager
class CryptoManager: CryptoManagerProtocol, Logging {

	/// Structure to hold cryptography data
	private struct CryptoData: Codable {

		/// The key of the holder
		var holderSecretKey: Data?
		var nonce: String?
		var stoken: String?
		var proofs: Data?

		/// Empty crypto data
		static var empty: CryptoData {
			return CryptoData(holderSecretKey: nil, nonce: nil, stoken: nil, proofs: nil)
		}
	}

	/// Array of constants
	private struct Constants {
		static let keychainService = "CryptoManager\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// The crypto data stored in the keychain
	@Keychain(name: "cryptoData", service: Constants.keychainService, clearOnReinstall: true)
	private var cryptoData: CryptoData = .empty

	/// The publc key of the issuer
	private var issuerPublicKey: Data?

	/// Initializer
	required init() {

		// Public Key
		readPublicKey()

		if cryptoData.holderSecretKey == nil {
			if let result = ClmobileGenerateHolderSk(),
			   let data = result.value {
				self.cryptoData = CryptoData(
					holderSecretKey: data,
					nonce: nil,
					stoken: nil
				)
			}
		}
	}

	/// Read the public key
	func readPublicKey() {

		if let content = FileReader(bundle: Bundle(for: type(of: self)), fileName: "issuerPk", fileType: "xml").read() {
			issuerPublicKey = content.data(using: .utf8)
		}
	}

	/// Debug method
	func debug() {

		if let holderSK = cryptoData.holderSecretKey {
			let holderSKString = String(decoding: holderSK, as: UTF8.self)
			self.logDebug("CryptoData:\n holderSK: \(holderSKString)\n nonce: \(cryptoData.nonce ?? "n/a")\n stoken: \(cryptoData.stoken ?? "n/a")")
		}
		if let issuerPK = issuerPublicKey {
			let issuerPublicKeyString = String(decoding: issuerPK, as: UTF8.self)
			self.logDebug("CryptoData:\n issuerPublicKey: \(String(issuerPublicKeyString.prefix(54))))")
		}
	}

	/// Generate the commitment message
	/// - Returns: the issuer commitment message
	func generateCommitmentMessage() -> String? {

		if let nonce = cryptoData.nonce,
		   let result = ClmobileCreateCommitmentMessage(
			cryptoData.holderSecretKey,
			issuerPublicKey,
			Data(nonce.bytes)
		   ) {
			if let value = result.value, result.error.isEmpty {
				let string = String(decoding: value, as: UTF8.self)
				return string
			} else {
				self.logDebug("ICM: \(result.error)")
			}
		}
		return nil
	}

	func generateQRmessage() -> String? {

		guard let holderSecretKey = cryptoData.holderSecretKey, let ism = cryptoData.proofs else {

			return nil
		}

		let credentails = ClmobileCreateCredential(holderSecretKey, ism)
		if let value = credentails?.value {
			let disclosed = ClmobileDiscloseAllWithTime(issuerPublicKey, value)
			if let base64Value = disclosed?.value?.base64EncodedString() {
				logDebug("QR message: \(base64Value)")
				return base64Value
			}
		}

		return nil
	}

	/// Set the nonce
	/// - Parameter nonce: the nonce
	func setNonce(_ nonce: String) {

		cryptoData.nonce = nonce
	}

	/// set the stoken
	/// - Parameter stoken: the stoken
	func setStoken(_ stoken: String) {

		cryptoData.stoken = stoken
	}

	/// Set the proofs
	/// - Parameter proofs: the test proofs
	func setProofs(_ proofs: Data?) {

		cryptoData.proofs = proofs
	}

	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String? {

		return cryptoData.stoken
	}

	func verifyQRMessage(_ message: String) -> Bool {

		let proofAsn1 = Data(base64Encoded: message)
		if let result = ClmobileVerify(issuerPublicKey, proofAsn1) {

			// This logic should not be here, it should only expose the attributes.
			return result.error.isEmpty && result.unixTimeSeconds > 0
		}
		return false
	}
}
