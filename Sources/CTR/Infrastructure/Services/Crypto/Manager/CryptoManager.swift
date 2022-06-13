/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

/// The cryptography manager
class CryptoManager: CryptoManaging {
	
	/// Structure to hold cryptography data
	struct CryptoData: Codable {
		
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
	
	private var cryptoData: CryptoData {
		get { secureUserSettings.cryptoData }
		set { secureUserSettings.cryptoData = newValue }
	}
	
	private let cryptoLibUtility: CryptoLibUtilityProtocol
	private let verificationPolicyManager: VerificationPolicyManaging
	private let secureUserSettings: SecureUserSettingsProtocol
	private let featureFlagManager: FeatureFlagManaging
	private let logHandler: Logging?
	
	/// Initializer

	required init(
		secureUserSettings: SecureUserSettingsProtocol,
		cryptoLibUtility: CryptoLibUtilityProtocol,
		verificationPolicyManager: VerificationPolicyManaging,
		featureFlagManager: FeatureFlagManaging,
		logHandler: Logging? = nil
	) {
		self.secureUserSettings = secureUserSettings
		self.cryptoLibUtility = cryptoLibUtility
		self.verificationPolicyManager = verificationPolicyManager
		self.featureFlagManager = featureFlagManager
		self.logHandler = logHandler
		
		// Initialize crypto library
		cryptoLibUtility.initialize()
	}
	
	func generateSecretKey() -> Data? {
		
		if let result = MobilecoreGenerateHolderSk(),
		   let data = result.value {
			return data
		} else {
			return nil
		}
	}
	
	/// Store the secret key
	/// - Parameter holderSecretKey: the holder secret key
	func storeSecretKey(_ holderSecretKey: Data) {
		
		self.cryptoData = CryptoData(
			holderSecretKey: holderSecretKey,
			nonce: nil,
			stoken: nil
		)
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
	
	/// Do we have public keys
	/// - Returns: True if we do
	func hasPublicKeys() -> Bool {
		
		return cryptoLibUtility.hasPublicKeys
	}
	
	func generateCommitmentMessage(holderSecretKey: Data) -> String? {

		if let nonce = cryptoData.nonce,
		   let result = MobilecoreCreateCommitmentMessage(holderSecretKey, Data(nonce.bytes)) {
			if let value = result.value, result.error.isEmpty {
				let string = String(decoding: value, as: UTF8.self)
				return string
			} else {
				logHandler?.logError("ICM: \(result.error)")
			}
		}
		return nil
	}
	
	// MARK: - QR

	///  Disclose the credential
	/// - Parameters:
	///   - credential: the (domestic) credential to generate the QR from
	///   - disclosurePolicy: the disclosure policy (1G / 3G) to genearte the QR with
	/// - Returns: the QR message
	func discloseCredential(_ credential: Data, disclosurePolicy: DisclosurePolicy) -> Data? {

		if let holderSecretKey = cryptoData.holderSecretKey, hasPublicKeys() {
			Current.logHandler.logVerbose("Disclosing with policy: \(disclosurePolicy)")
			let disclosed = MobilecoreDisclose(holderSecretKey, credential, disclosurePolicy.mobileDisclosurePolicy)
			if let payload = disclosed?.value {
				let message = String(decoding: payload, as: UTF8.self)
				logHandler?.logVerbose("QR message: \(message)")
				return payload
			} else if let error = disclosed?.error {
				logHandler?.logError("generateQRmessage: \(error)")
			}
		}
		
		return nil
	}
	
	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Verification result if the QR is valid or error if not
	func verifyQRMessage(_ message: String) -> Result<MobilecoreVerificationResult, CryptoError> {
		
		guard hasPublicKeys() else {
			logHandler?.logError("No public keys")
			return .failure(.keyMissing)
		}
		
		let proofQREncoded = message.data(using: .utf8)

		let scanPolicy: String
		if featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			guard let riskSetting = verificationPolicyManager.state else {
				assertionFailure("Risk level should be set")
				return .failure(.noRiskSetting)
			}
			scanPolicy = riskSetting.scanPolicy
		} else {
			guard let storedScanPolicy = Current.userSettings.configVerificationPolicies.first?.scanPolicy else {
				assertionFailure("Scan policy should be stored")
				return .failure(.noDefaultVerificationPolicy)
			}
			scanPolicy = storedScanPolicy
		}
		
		guard let result = MobilecoreVerify(proofQREncoded, scanPolicy) else {
			logHandler?.logError("Could not verify QR")
			return .failure(.couldNotVerify)
		}

		return .success(result)
	}
	
	// MARK: - Credential

	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes? {

		if let response = MobilecoreReadDomesticCredential(data) {
			if let value = response.value {
				do {
					let object = try JSONDecoder().decode(DomesticCredentialAttributes.self, from: value)
					return object
				} catch {
					logHandler?.logError("Error Deserializing \(DomesticCredentialAttributes.self): \(error)")
				}
			} else {
				logHandler?.logError("Can't read credential: \(String(describing: response.error))")
			}
		}
		return nil
	}
	
	var euCredentialAttributesCache: [Data: EuCredentialAttributes?] = [:]
	
	/// Read the crypto credential
	/// - Returns: the crypto attributes
	func readEuCredentials(_ data: Data) -> EuCredentialAttributes? {
		
		if let entry = euCredentialAttributesCache[data.sha256] {
			logHandler?.logVerbose("Using cache hit for \(String(decoding: data, as: UTF8.self))")
			return entry
		}
		
		if let response = MobilecoreReadEuropeanCredential(data) {
			if let value = response.value {
				do {
					logHandler?.logVerbose("EuCredentialAttributes Raw: \(String(decoding: value, as: UTF8.self))")
					let object = try JSONDecoder().decode(EuCredentialAttributes.self, from: value)
					euCredentialAttributesCache[data.sha256] = object
					return object
				} catch {
					logHandler?.logError("Error: \(String(decoding: value, as: UTF8.self))")
					logHandler?.logError("Error Deserializing \(EuCredentialAttributes.self): \(error)")
				}
			} else {
				logHandler?.logError("Can't read credential: \(String(describing: response.error))")
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
			logHandler?.logError("Can't create credential: \(String(describing: reason))")
			return .failure(CryptoError.credentialCreateFail(reason: reason))
		}
		return .failure(CryptoError.unknown)
	}
	
	/// Is this data a foreign DCC
	/// - Parameter data: the data of the DCC
	/// - Returns: True if the DCC is foreign
	func isForeignDCC(_ data: Data) -> Bool {
		
		return MobilecoreIsForeignDCC(data)
	}
	
	/// Is this data a DCC
	/// - Parameter data: the data
	/// - Returns: True if the data is a DCC
	func isDCC(_ data: Data) -> Bool {
		
		return MobilecoreIsDCC(data)
	}
	
	/// Is this data a CTB
	/// - Parameter data: the data
	/// - Returns: True if the data is a CTB
	func hasDomesticPrefix(_ data: Data) -> Bool {
		
		return MobilecoreHasDomesticPrefix(data)
	}
}
