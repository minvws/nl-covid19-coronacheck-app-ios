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

struct IssuerPublicKey: Codable {
	
	var identifier: String
	var publicKey: String
	
	enum CodingKeys: String, CodingKey {
		
		case identifier = "id"
		case publicKey = "public_key"
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
	
	/// Set the issuer public keys
	/// - Parameter keys: the keys
	func setIssuerPublicKeys(_ keys: [IssuerPublicKey]) -> Bool
	
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

struct DomesticCredentialAttributes: Codable {

	let birthDay: String
	let birthMonth: String
	let firstNameInitial: String
	let lastNameInitial: String
	let credentialVersion: String
	let specimen: String
	let paperProof: String
	let validFrom: String
	let validForHours: String

	enum CodingKeys: String, CodingKey {

		case birthDay
		case birthMonth
		case firstNameInitial
		case lastNameInitial
		case credentialVersion
		case specimen = "isSpecimen"
		case paperProof = "stripType"
		case validFrom
		case validForHours
	}

	var isPaperProof: Bool {

		return paperProof == "1"
	}

	var isSpecimen: Bool {

		return specimen == "1"
	}

	/// Map the identity of the holder
	/// - Parameter months: the months
	/// - Returns: mapped identify
	func mapIdentity(months: [String]) -> [String] {

		var output: [String] = []
		output.append(firstNameInitial)
		output.append(lastNameInitial)
		if let value = Int(birthDay), value > 0 {
			let formatter = NumberFormatter()
			formatter.minimumIntegerDigits = 2
			if let day = formatter.string(from: NSNumber(value: value)) {
				output.append(day)
			}
		} else {
			output.append(birthDay)
		}

		if let value = Int(birthMonth), value <= months.count, value > 0 {
			output.append(months[value - 1])
		} else {
			output.append(birthMonth)
		}

		return output
	}
}

struct DomesticCredential: Codable {

	let credential: Data?
	let attributes: DomesticCredentialAttributes

	enum CodingKeys: String, CodingKey {

		case credential
		case attributes
	}

	init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		attributes = try container.decode(DomesticCredentialAttributes.self, forKey: .attributes)
		let structure = try container.decode(AnyCodable.self, forKey: .credential)
		let jsonEncoder = JSONEncoder()

		if let data = try? jsonEncoder.encode(structure),
		   let str = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/") {
			credential = Data(str.utf8)
		} else {
			credential = nil
		}
	}
}

struct EuCredentialAttributes: Codable {

	struct DigitalCovidCertificate: Codable {

		let dateOfBirth: String
		let name: Name
		let schemaVersion: String
		var vaccinations: [Vaccination] = []

		enum CodingKeys: String, CodingKey {

			case dateOfBirth = "dob"
			case name = "nam"
			case schemaVersion = "ver"
			case vaccinations = "v"
		}
	}

	struct Name: Codable {

		let firstName: String
		let standardisedFirstName: String
		let givenName: String
		let standardisedGivenName: String

		enum CodingKeys: String, CodingKey {

			case firstName = "fn"
			case standardisedFirstName = "fnt"
			case givenName = "gn"
			case standardisedGivenName = "gnt"
		}
	}

	struct Vaccination: Codable {

		let cerficateIdentifier: String
		let country: String
		let doseNumber: Int
		let dateOfVaccination: String
		let issuer: String
		let marketingAuthorizationHolder: String
		let vaccineMedicalProduct: String
		let totalDose: Int
		let diseaseAgentTargeted: String
		let vaccineOrProphylaxis: String

		enum CodingKeys: String, CodingKey {

			case cerficateIdentifier = "ci"
			case country = "co"
			case doseNumber = "dn"
			case dateOfVaccination = "dt"
			case issuer = "is"
			case marketingAuthorizationHolder = "ma"
			case vaccineMedicalProduct = "mp"
			case totalDose = "sd"
			case diseaseAgentTargeted = "tg"
			case vaccineOrProphylaxis = "vp"
		}
	}

	let credentialVersion: Int
	let digitialCovidCertificate: DigitalCovidCertificate
	let expirationTime: TimeInterval
	let issuedAt: TimeInterval
	let issuer: String

	enum CodingKeys: String, CodingKey {

		case credentialVersion
		case digitialCovidCertificate = "dcc"
		case expirationTime
		case issuedAt
		case issuer
	}
}
