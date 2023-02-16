/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore
import Shared
import Models

/// The cryptography manager
public class CryptoManager: CryptoManaging {
	
	private let cryptoLibUtility: CryptoLibUtilityProtocol
	private let verificationPolicyManager: VerificationPolicyManaging
	private let featureFlagManager: FeatureFlagManaging
	private let userSettings: UserSettingsProtocol
	
	/// Initializer

	public required init(
		cryptoLibUtility: CryptoLibUtilityProtocol,
		verificationPolicyManager: VerificationPolicyManaging,
		featureFlagManager: FeatureFlagManaging,
		userSettings: UserSettingsProtocol
	) {
		self.cryptoLibUtility = cryptoLibUtility
		self.verificationPolicyManager = verificationPolicyManager
		self.featureFlagManager = featureFlagManager
		self.userSettings = userSettings
		
		// Initialize crypto library
		cryptoLibUtility.initialize()
	}
	
	public func generateSecretKey() -> Data? {
		
		if let result = MobilecoreGenerateHolderSk(),
		   let data = result.value {
			return data
		} else {
			return nil
		}
	}
	
	/// Do we have public keys
	/// - Returns: True if we do
	public func hasPublicKeys() -> Bool {
		
		return cryptoLibUtility.hasPublicKeys
	}
	
	public func generateCommitmentMessage(nonce: String, holderSecretKey: Data) -> String? {

		if let result = MobilecoreCreateCommitmentMessage(holderSecretKey, Data(nonce.bytes)) {
			if let value = result.value, result.error.isEmpty {
				let string = String(decoding: value, as: UTF8.self)
				return string
			} else {
				logError("ICM: \(result.error)")
			}
		}
		return nil
	}
	
	// MARK: - QR
	
	public func discloseCredential(_ credential: Data, forPolicy disclosurePolicy: DisclosurePolicy, withKey holderSecretKey: Data) -> Data? {

		if hasPublicKeys() {
			logVerbose("Disclosing with policy: \(disclosurePolicy)")
			let disclosed = MobilecoreDisclose(holderSecretKey, credential, disclosurePolicy.mobileDisclosurePolicy)
			if let payload = disclosed?.value {
				let message = String(decoding: payload, as: UTF8.self)
				logVerbose("QR message: \(message)")
				return payload
			} else if let error = disclosed?.error {
				logError("generateQRmessage: \(error)")
			}
		}
		
		return nil
	}
	
	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Verification result if the QR is valid or error if not
	public func verifyQRMessage(_ message: String) -> Result<MobilecoreVerificationResult, CryptoError> {
		
		guard hasPublicKeys() else {
			logError("No public keys")
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
			guard let storedScanPolicy = userSettings.configVerificationPolicies.first?.scanPolicy else {
				assertionFailure("Scan policy should be stored")
				return .failure(.noDefaultVerificationPolicy)
			}
			scanPolicy = storedScanPolicy
		}
		
		guard let result = MobilecoreVerify(proofQREncoded, scanPolicy) else {
			logError("Could not verify QR")
			return .failure(.couldNotVerify)
		}

		return .success(result)
	}
	
	// MARK: - Credential

	/// Read the crypto credential
	/// - Returns: the crypto attributes
	public func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes? {

		if let response = MobilecoreReadDomesticCredential(data) {
			if let value = response.value {
				do {
					let object = try JSONDecoder().decode(DomesticCredentialAttributes.self, from: value)
					return object
				} catch {
					logError("Error Deserializing \(DomesticCredentialAttributes.self): \(error)")
				}
			} else {
				logError("Can't read credential: \(String(describing: response.error))")
			}
		}
		return nil
	}
	
	public var euCredentialAttributesCache = ThreadSafeCache<Data, EuCredentialAttributes?>()
	
	/// Read the crypto credential
	/// - Returns: the crypto attributes
	public func readEuCredentials(_ data: Data) -> EuCredentialAttributes? {
		
		if let entry = euCredentialAttributesCache[data.sha256] {
			logVerbose("Using cache hit for \(String(decoding: data, as: UTF8.self))")
			return entry
		}
		
		if let response = MobilecoreReadEuropeanCredential(data) {
			if let value = response.value {
				do {
					logVerbose("EuCredentialAttributes Raw: \(String(decoding: value, as: UTF8.self))")
					let object = try JSONDecoder().decode(EuCredentialAttributes.self, from: value)
					euCredentialAttributesCache[data.sha256] = object
					return object
				} catch {
					logError("Error: \(String(decoding: value, as: UTF8.self))")
					logError("Error Deserializing \(EuCredentialAttributes.self): \(error)")
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
	public func createCredential(_ ism: Data) -> Result<Data, CryptoError> {
		
		let result = MobilecoreCreateCredentials(ism)
		if let credential = result?.value {
			return .success(credential)
		} else if let reason = result?.error {
			logError("Can't create credential: \(String(describing: reason))")
			return .failure(CryptoError.credentialCreateFail(reason: reason))
		}
		return .failure(CryptoError.unknown)
	}
	
	/// Is this data a foreign DCC
	/// - Parameter data: the data of the DCC
	/// - Returns: True if the DCC is foreign
	public func isForeignDCC(_ data: Data) -> Bool {
		
		return MobilecoreIsForeignDCC(data)
	}
	
	/// Is this data a DCC
	/// - Parameter data: the data
	/// - Returns: True if the data is a DCC
	public func isDCC(_ data: Data) -> Bool {
		
		return MobilecoreIsDCC(data)
	}
	
	/// Is this data a CTB
	/// - Parameter data: the data
	/// - Returns: True if the data is a CTB
	public func hasDomesticPrefix(_ data: Data) -> Bool {
		
		return MobilecoreHasDomesticPrefix(data)
	}
}
