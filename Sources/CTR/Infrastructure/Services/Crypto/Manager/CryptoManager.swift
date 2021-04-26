/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

/// The cryptography manager
class CryptoManager: CryptoManaging, Logging {
	
	/// Structure to hold key data
	private struct KeyData: Codable {
		
		/// The issuer public keys
		var issuerPublicKeys: Data?
		
		/// Empty key data
		static var empty: KeyData {
			return KeyData(issuerPublicKeys: nil)
		}
	}
	
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
		static let keychainService = "CryptoManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}
	
	/// The crypto data stored in the keychain
	@Keychain(name: "cryptoData", service: Constants.keychainService, clearOnReinstall: true)
	private var cryptoData: CryptoData = .empty
	
	/// The key data stored in the keychain
	@Keychain(name: "keyData", service: Constants.keychainService, clearOnReinstall: true)
	private var keyData: KeyData = .empty
	
	/// Initializer
	required init() {
		
		// Public Key
		loadPublicKeys()
		
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
	
	/// Set the issuer public keys
	/// - Parameter keys: the keys
	func setIssuerPublicKeys(_ keys: [IssuerPublicKey]) -> Bool {
		
		let keysAsString = generateString(object: keys)
		let keysAsData = Data(keysAsString.bytes)
		keyData.issuerPublicKeys = keysAsData
		logInfo("Stored \(keys.count) issuer public keys in the keychain")
		return loadPublicKeys()
	}
	
	/// Generate a string from a codable object
	/// - Parameter object: the object to flatten into a string
	/// - Returns: flattend object
	private func generateString<T>(object: T) -> String where T: Codable {
		
		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .utf8) {
			return convertedToString
		}
		return ""
	}
	
	/// Load the public keys
	@discardableResult func loadPublicKeys() -> Bool {

		guard let keysAsData = keyData.issuerPublicKeys,
			  let result = ClmobileLoadIssuerPks(keysAsData) else {

			return false
		}

		if !result.error.isEmpty {
			logError("Error loading public keys: \(result.error)")
		}

		return result.error.isEmpty
	}
	
	/// Do we have public keys
	/// - Returns: True if we do
	func hasPublicKeys() -> Bool {
		
		return keyData.issuerPublicKeys != nil
	}
	
	/// Generate the commitment message
	/// - Returns: the issuer commitment message
	func generateCommitmentMessage() -> String? {
		
		if let nonce = cryptoData.nonce,
		   let result = ClmobileCreateCommitmentMessage(cryptoData.holderSecretKey, Data(nonce.bytes)) {
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
		
		guard hasPublicKeys() else {
			return nil
		}
		
		let disclosed = ClmobileDiscloseAllWithTimeQrEncoded(holderSecretKey, credential)
		if let payload = disclosed?.value {
			let message = String(decoding: payload, as: UTF8.self)
			logDebug("QR message: \(message)")
			return payload
		}
		return nil
	}
	
	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Attributes if the QR is valid or error string if not
	func verifyQRMessage(_ message: String) -> CryptoResult {
		
		guard hasPublicKeys() else {
			return (attributes: nil, errorMessage: "no public keys")
		}
		
		let proofAsn1QREncoded = message.data(using: .utf8)
		if let result = ClmobileVerifyQREncoded(proofAsn1QREncoded) {
			
			guard result.error.isEmpty, let attributesJson = result.attributesJson else {
				self.logError("Error Proof: \(result.error)")
				return (attributes: nil, errorMessage: result.error)
			}
			
			do {
				let object = try JSONDecoder().decode(CryptoAttributes.self, from: attributesJson)
				return (Attributes(cryptoAttributes: object, unixTimeStamp: result.unixTimeSeconds), nil)
			} catch {
				self.logError("Error Deserializing \(CryptoAttributes.self): \(error)")
				return (attributes: nil, errorMessage: error.localizedDescription)
			}
		}
		return (attributes: nil, errorMessage: "could not verify QR")
	}
	
	// MARK: - Credential
	
	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readCredential() -> CryptoAttributes? {
		
		if let cryptoDataValue = cryptoData.credential,
		   let response = ClmobileReadCredential(cryptoDataValue) {
			if let value = response.value {
				do {
					let object = try JSONDecoder().decode(CryptoAttributes.self, from: value)
					return object
				} catch {
					self.logError("Error Deserializing \(CryptoAttributes.self): \(error)")
				}
			} else {
				logError("Can't read credential: \(String(describing: response.error))")
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
