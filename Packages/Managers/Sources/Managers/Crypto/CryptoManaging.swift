/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore
import Models

public protocol CryptoManaging: AnyObject {
	
	// MARK: Encryption
	
	/// Generate a secret key
	/// - Returns: optional secret key
	func generateSecretKey() -> Data?
	
	/// Generate the commitment message
	/// - Parameters:
	///   - nonce: The nonce
	///   - holderSecretKey: the holder secret key
	/// - Returns: commitment message
	func generateCommitmentMessage(nonce: String, holderSecretKey: Data) -> String?
	
	// MARK: Public Keys
	
	/// Do we have public keys
	/// - Returns: True if we do
	func hasPublicKeys() -> Bool
	
	// MARK: Credential
	
	/// Create the credential from the issuer commit message
	/// - Parameter ism: the issuer commit message (signed testproof)
	/// - Returns: Credential data if success, error if not
	func createCredential(_ ism: Data) -> Result<Data, CryptoError>
	
	/// Is this data a foreign DCC
	/// - Parameter data: the data of the DCC
	/// - Returns: True if the DCC is foreign
	func isForeignDCC(_ data: Data) -> Bool
	
	/// Is this data a DCC
	/// - Parameter data: the data
	/// - Returns: True if the data is a DCC
	func isDCC(_ data: Data) -> Bool
	
	/// Does this look like a domestic credential
	/// - Parameter data: the data
	/// - Returns: True if the data looks like a domestic credential
	func hasDomesticPrefix(_ data: Data) -> Bool
	
	/// Get the domestic credential attributes
	/// - Parameter data: the incoming domestic ctb
	/// - Returns: optional domstic credential attributes
	func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes?
	
	/// Get the eu credential attributes
	/// - Parameter data: the incoming eu dcc
	/// - Returns: optional eu credential attributes
	func readEuCredentials(_ data: Data) -> EuCredentialAttributes?
	
	// MARK: QR
	
	/// Disclose the credential
	/// - Parameters:
	///   - credential: the (domestic) credential to generate the QR from
	///   - forPolicy: the disclosure policy (1G / 3G) to genearte the QR with
	///   - withKey: the holder secret key
	/// - Returns: the QR message
	func discloseCredential(_ credential: Data, forPolicy disclosurePolicy: DisclosurePolicy, withKey holderSecretKey: Data) -> Data?
	
	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Verification result if the QR is valid or error if not
	func verifyQRMessage(_ message: String) -> Result<MobilecoreVerificationResult, CryptoError>
}

/// The errors returned by the crypto library
public enum CryptoError: Error {

	case keyMissing
	case credentialCreateFail(reason: String)
	case unknown
	case noRiskSetting
	case noDefaultVerificationPolicy
	case couldNotVerify
}
