/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

typealias CryptoResult = (attributes: Attributes?, errorMessage: String?)

struct NonceEnvelope: Codable {
	
	let nonce: String
	let stoken: String
}

struct PrepareIssueEnvelope: Codable {

	let prepareIssueMessage: String
	let stoken: String
}

struct CryptoAttributes: Codable {
	
	let birthDay: String?
	let birthMonth: String?
	let firstNameInitial: String?
	let lastNameInitial: String?
	let sampleTime: String
	let testType: String
	let specimen: String?
	let paperProof: String?
	
	enum CodingKeys: String, CodingKey {
		
		case birthDay
		case birthMonth
		case firstNameInitial
		case lastNameInitial
		case sampleTime
		case testType
		case specimen = "isSpecimen"
		case paperProof = "isPaperProof"
	}
	
	var isPaperProof: Bool {
		
		return paperProof == "1"
	}
	
	var isSpecimen: Bool {
		
		return specimen == "1"
	}
}

struct Attributes {
	
	let cryptoAttributes: CryptoAttributes
	let unixTimeStamp: Int64
}

struct IssuerDomesticPublicKey: Codable {
	
	let identifier: String
	let publicKey: String
	
	enum CodingKeys: String, CodingKey {
		
		case identifier = "id"
		case publicKey = "public_key"
	}
}

struct IssuerPublicKeys: Codable {
	
	let clKeys: [IssuerDomesticPublicKey]
	
	enum CodingKeys: String, CodingKey {
		
		case clKeys = "cl_keys"
	}
}

protocol CryptoManaging: AnyObject {
	
	init()
	
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
	
	/// Set the issuer domestic public keys
	/// - Parameter keys: the keys
	func setIssuerDomesticPublicKeys(_ keys: IssuerPublicKeys) -> Bool
	
	/// Do we have public keys
	/// - Returns: True if we do
	func hasPublicKeys() -> Bool
	
	// MARK: Credential

	/// Create the credential from the issuer commit message
	/// - Parameter ism: the issuer commit message (signed testproof)
	/// - Returns: Credential data if success, error if not
	func createCredential(_ ism: Data) -> Result<Data, CryptoError>
	
	/// Read the crypto credential
	/// - Returns: the  the crypto attributes
	func readCredential() -> CryptoAttributes?

	/// Store the credential in the vault
	/// - Parameter credential: the credential
	func storeCredential(_ credential: Data)

	/// Remove the credential
	func removeCredential()
	
	// MARK: QR

	/// Generate the QR message
	/// - Parameter credential: the (domestic) credential to generate the QR from
	/// - Returns: the QR message
	func generateQRmessage(_ credential: Data) -> Data?
	
	/// Verify the QR message
	/// - Parameter message: the scanned QR code
	/// - Returns: Attributes if the QR is valid or error string if not
	func verifyQRMessage(_ message: String) -> CryptoResult

	// MARK: Migration

	func migrateExistingCredential(_ walletManager: WalletManaging)

	func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes?

	func readEuCredentials(_ data: Data) -> EuCredentialAttributes?
}

/// The errors returned by the crypto library
enum CryptoError: Error {

	case keyMissing
	case credentialCreateFail(reason: String)
	case unknown
}
