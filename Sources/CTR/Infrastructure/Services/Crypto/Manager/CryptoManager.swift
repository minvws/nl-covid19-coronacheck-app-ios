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
	
	private let cryptoVerifierUtility: CryptoVerifierUtility = Services.cryptoVerifierUtility
	
	/// Initializer
	required init() {
		
		// Public Key
		loadPublicKeys()
		
		// Initialize verifier
		cryptoVerifierUtility.initialize()
		
		if cryptoData.holderSecretKey == nil && AppFlavor.flavor == .holder {
			if let result = MobilecoreGenerateHolderSk(),
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
	
	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String? {
		
		return cryptoData.stoken
	}
	
	/// Set the issuer domestic public keys
	/// - Parameter keys: the keys
	func setIssuerDomesticPublicKeys(_ keys: IssuerPublicKeys) -> Bool {
		
		let domesticKeys = keys.clKeys
		let keysAsString = generateString(object: domesticKeys)
		let keysAsData = Data(keysAsString.bytes)
		keyData.issuerPublicKeys = keysAsData
		logInfo("Stored \(domesticKeys.count) issuer domestic public keys in the keychain")
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
			  let result = MobilecoreLoadDomesticIssuerPks(keysAsData) else {

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
		   let result = MobilecoreCreateCommitmentMessage(cryptoData.holderSecretKey, Data(nonce.bytes)) {
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
	/// - Parameter credential: the (domestic) credential to generate the QR from
	/// - Returns: the QR message
	func generateQRmessage(_ credential: Data) -> Data? {

		if let holderSecretKey = cryptoData.holderSecretKey, hasPublicKeys() {
			let disclosed = MobilecoreDisclose(holderSecretKey, credential)
			if let payload = disclosed?.value {
				let message = String(decoding: payload, as: UTF8.self)
				logDebug("QR message: \(message)")
				return payload
			} else if let error = disclosed?.error {
				logError("generateQRmessage: \(error)")
			}
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

//		if let result = MobilecoreVerifyQREncoded(proofAsn1QREncoded) {
//
//			guard result.error.isEmpty, let attributesJson = result.attributesJson else {
//				self.logError("Error Proof: \(result.error)")
//				return (attributes: nil, errorMessage: result.error)
//			}
//
//			do {
//				let object = try JSONDecoder().decode(CryptoAttributes.self, from: attributesJson)
//				return (Attributes(cryptoAttributes: object, unixTimeStamp: result.unixTimeSeconds), nil)
//			} catch {
//				self.logError("Error Deserializing \(CryptoAttributes.self): \(error)")
//				return (attributes: nil, errorMessage: error.localizedDescription)
//			}
//		}
		return (attributes: nil, errorMessage: "could not verify QR")
	}
	
	// MARK: - Credential
	
	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readCredential() -> CryptoAttributes? {
		
		if let cryptoDataValue = cryptoData.credential,
		   let response = MobilecoreReadDomesticCredential(cryptoDataValue) {
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

	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes? {

		if let response = MobilecoreReadDomesticCredential(data) {
			if let value = response.value {
				do {
					let object = try JSONDecoder().decode(DomesticCredentialAttributes.self, from: value)
					return object
				} catch {
					self.logError("Error Deserializing \(DomesticCredentialAttributes.self): \(error)")
				}
			} else {
				logError("Can't read credential: \(String(describing: response.error))")
			}
		}
		return nil
	}

	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readEuCredentials(_ data: Data) -> EuCredentialAttributes? {

		if let response = MobilecoreReadEuropeanCredential(data) {
			if let value = response.value {
				do {
					let object = try JSONDecoder().decode(EuCredentialAttributes.self, from: value)
					return object
				} catch {
					self.logError("Error: \(String(decoding: value, as: UTF8.self))")
					self.logError("Error Deserializing \(EuCredentialAttributes.self): \(error)")
				}
			} else {
				logError("Can't read credential: \(String(describing: response.error))")
			}
		}
		return nil
	}

	/// Create the credential from the issuer commit message
	/// - Parameter ism: the issuer commit message (signed testproof)
	/// - Returns: Credential data if success, error if not
	func createCredential(_ ism: Data) -> Result<Data, CryptoError> {

		let result = MobilecoreCreateCredentials(ism)
		if let credential = result?.value {
			return .success(credential)
		} else if let reason = result?.error {
			logError("Can't create credential: \(String(describing: reason))")
			return .failure(CryptoError.credentialCreateFail(reason: reason))
		}
		return .failure(CryptoError.unknown)
	}

	/// Store the credential in the vault
	/// - Parameter credential: the credential
	func storeCredential(_ credential: Data) {

		cryptoData.credential = credential
	}
	
	/// Remove the credential
	func removeCredential() {
		
		cryptoData.credential = nil
	}

	/// Migrate existing credential to the wallet
	/// - Parameter walletManager: the wallet manager
	func migrateExistingCredential(_ walletManager: WalletManaging) {

		if let existingCredential = cryptoData.credential,
		   let cryptoAttributes = readCredential(),
			let sampleTime = TimeInterval(cryptoAttributes.sampleTime),
			walletManager.importExistingTestCredential(existingCredential, sampleDate: Date(timeIntervalSince1970: sampleTime)) {

				removeCredential()
		}
	}
}
