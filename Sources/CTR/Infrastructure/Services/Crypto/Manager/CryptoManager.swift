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
	private let riskLevelManager: RiskLevelManaging
	private let secureUserSettings: SecureUserSettingsProtocol
	private let featureFlagManager: FeatureFlagManaging
	
	/// Initializer

	required init(
		secureUserSettings: SecureUserSettingsProtocol,
		cryptoLibUtility: CryptoLibUtilityProtocol,
		riskLevelManager: RiskLevelManaging,
		featureFlagManager: FeatureFlagManaging
	) {
		self.secureUserSettings = secureUserSettings
		self.cryptoLibUtility = cryptoLibUtility
		self.riskLevelManager = riskLevelManager
		self.featureFlagManager = featureFlagManager
		
		// Initialize crypto library
		cryptoLibUtility.initialize()
		generateSecretKey()
	}
	
	func generateSecretKey() {
		
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
	
	/// Do we have public keys
	/// - Returns: True if we do
	func hasPublicKeys() -> Bool {
		
		return cryptoLibUtility.hasPublicKeys
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
			let disclosed = MobilecoreDisclose(holderSecretKey, credential, MobilecoreDISCLOSURE_POLICY_3G)
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
	/// - Returns: Verification result if the QR is valid or nil if not
	func verifyQRMessage(_ message: String) -> MobilecoreVerificationResult? {
		
		guard hasPublicKeys() else {
			logError("No public keys")
			return nil
		}
		
		let proofQREncoded = message.data(using: .utf8)

		let scanPolicy: Int
		if featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			guard let riskSetting = riskLevelManager.state else {
				assertionFailure("Risk level should be set")
				return nil
			}
			scanPolicy = riskSetting.scanPolicy
		} else {
			guard let storedScanPolicy = Current.userSettings.configVerificationPolicies.first?.scanPolicy else {
				assertionFailure("Scan policy should be stored")
				return nil
			}
			scanPolicy = storedScanPolicy
		}
		
		guard let result = MobilecoreVerify(proofQREncoded, scanPolicy) else {
			logError("Could not verify QR")
			return nil
		}

		return result
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
					logVerbose("EuCredentialAttributes Raw: \(String(decoding: value, as: UTF8.self))")
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
}
