/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Ctcl

struct NonceEnvelope: Codable {

	let nonce: String
	let stoken: String
}

struct CrypoAttributes: Codable {

	let sampleTime: String
	let testType: String
}

struct Attributes {

	let cryptoAttributes: CrypoAttributes
	let unixTimeStamp: Int64
}

protocol CryptoManaging: AnyObject {

	init()

	/// Set the nonce
	/// - Parameter nonce: the nonce
	func setNonce(_ nonce: String)

	/// set the stoken
	/// - Parameter stoken: the stoken
	func setStoken(_ stoken: String)

	/// Set the signature message
	/// - Parameter proofs: the signature message (signed proof)
	func setTestProof(_ proof: Data?)

	/// Generate the commitment message
	/// - Returns: commitment message
	func generateCommitmentMessage() -> String?

	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String?

	/// Create the credential
	func createCredential()

	/// Read the crypto credential
	/// - Returns: the  the crypto attributes
	func readCredential() -> CrypoAttributes?

	/// Remove the credial
	func removeCredential()

	/// Generate the QR message
	/// - Returns: the QR message
	func generateQRmessage() -> Data?

	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: True if valid
	func verifyQRMessage(_ message: String) -> Attributes?
}

/// The cryptography manager
class CryptoManager: CryptoManaging, Logging {

	/// Structure to hold cryptography data
	private struct CryptoData: Codable {

		/// The key of the holder
		var holderSecretKey: Data?
		var nonce: String?
		var stoken: String?
		var ism: Data?
		var credential: Data?

		/// Empty crypto data
		static var empty: CryptoData {
			return CryptoData(holderSecretKey: nil, nonce: nil, stoken: nil, ism: nil, credential: nil)
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

		if cryptoData.holderSecretKey == nil && AppFlavor.flavor == .holder {
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

	// MARK: - Getters and Setters

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

	/// Set the signature message
	/// - Parameter proof: the signature message (signed proof)
	func setTestProof(_ proof: Data?) {

		cryptoData.ism = proof
		cryptoData.credential = nil
	}

	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String? {

		return cryptoData.stoken
	}

	/// Read the public key
	func readPublicKey() {

		if let content = FileReader(bundle: Bundle(for: type(of: self)), fileName: "issuerPk", fileType: "xml").read() {
			issuerPublicKey = content.data(using: .utf8)
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
			let xxx = Data(nonce.bytes)
			if let value = result.value, result.error.isEmpty {
				let string = String(decoding: value, as: UTF8.self)
				return string
			} else {
				self.logDebug("ICM: \(result.error)")
			}
		}
		return nil
	}

	// MARK: - QR

	/// Generate the QR message
	/// - Returns: the QR message
	func generateQRmessage() -> Data? {

		if let credential = cryptoData.credential, let holderSecretKey = cryptoData.holderSecretKey {
			return createQRMessage(credential, holderSecretKey: holderSecretKey)
		}

		return nil
	}

	/// Create the QR Message
	/// - Parameters:
	///   - credential: the credential
	///   - holderSecretKey: the holder Secret Key
	/// - Returns: QR Messaga as Data
	private func createQRMessage(_ credential: Data?, holderSecretKey: Data) -> Data? {

		let disclosed = ClmobileDiscloseAllWithTimeQrEncoded(issuerPublicKey, holderSecretKey, credential)
		if let payload = disclosed?.value {
			let message = String(decoding: payload, as: UTF8.self)
			logDebug("QR message: \(message)")
			return payload
		}
		return nil
	}

	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Attributes if the QR is valid
	func verifyQRMessage(_ message: String) -> Attributes? {

		let proofAsn1QREncoded = message.data(using: .utf8)
		if let result = ClmobileVerifyQREncoded(issuerPublicKey, proofAsn1QREncoded) {

			guard result.error.isEmpty, let attributesJson = result.attributesJson else {
				self.logError("Error Proof: \(result.error)")
				return nil
			}

			do {
				let object = try JSONDecoder().decode(CrypoAttributes.self, from: attributesJson)
				return Attributes(cryptoAttributes: object, unixTimeStamp: result.unixTimeSeconds)
			} catch {
				self.logError("Error Deserializing \(CrypoAttributes.self): \(error)")
				return nil
			}
		}
		return nil
	}

	// MARK: - Credential

	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readCredential() -> CrypoAttributes? {

		if let cryptoDataValue = cryptoData.credential,
		   let response = ClmobileReadCredential(cryptoDataValue),
		   let value = response.value {
			do {
				let object = try JSONDecoder().decode(CrypoAttributes.self, from: value)
				return object
			} catch {
				self.logError("Error Deserializing \(CrypoAttributes.self): \(error)")
				return nil
			}
		}
		return nil
	}

	/// Create the credential
	func createCredential() {

		guard let holderSecretKey = cryptoData.holderSecretKey,
			  let ism = cryptoData.ism else {
			return
		}
		let result = ClmobileCreateCredential(holderSecretKey, ism)
		if let credential = result?.value {
			cryptoData.credential = credential
		} else {
			logError("Can't create credential: \(String(describing: result?.error))")
		}
	}

	/// Remove the credial
	func removeCredential() {

		cryptoData.credential = nil
	}
}
