/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

struct NonceEnvelope: Codable {
	
	let nonce: String
	let stoken: String
}

struct PrepareIssueEnvelope: Codable {

	let prepareIssueMessage: String
	let stoken: String
}

protocol CryptoManaging: AnyObject {
	
	init(secureUserSettings: SecureUserSettingsProtocol)
	
	// MARK: Encryption
	
	/// Set the nonce
	/// - Parameter nonce: the nonce
	func setNonce(_ nonce: String)
	
	/// set the stoken
	/// - Parameter stoken: the stoken
	func setStoken(_ stoken: String)
	
	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String?
	
	/// Generate the commitment message
	/// - Returns: commitment message
	func generateCommitmentMessage() -> String?
	
	// MARK: Public Keys
	
	/// Do we have public keys
	/// - Returns: True if we do
	func hasPublicKeys() -> Bool
	
	// MARK: Credential

	/// Create the credential from the issuer commit message
	/// - Parameter ism: the issuer commit message (signed testproof)
	/// - Returns: Credential data if success, error if not
	func createCredential(_ ism: Data) -> Result<Data, CryptoError>
	
	// MARK: QR

	/// Generate the QR message
	/// - Parameter credential: the (domestic) credential to generate the QR from
	/// - Returns: the QR message
	func generateQRmessage(_ credential: Data) -> Data?
	
	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Attributes if the QR is valid or error string if not
	func verifyQRMessage(_ message: String) -> MobilecoreVerificationResult?

	// MARK: Migration

	func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes?

	func readEuCredentials(_ data: Data) -> EuCredentialAttributes?
}

/// The errors returned by the crypto library
enum CryptoError: Error {

	case keyMissing
	case credentialCreateFail(reason: String)
	case unknown
}
