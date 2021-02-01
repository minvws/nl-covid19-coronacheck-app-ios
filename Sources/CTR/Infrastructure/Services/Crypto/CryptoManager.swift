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

protocol CryptoManagerProtocol {

	init()

	func debug()

	/// Set the nonce
	/// - Parameter nonce: the nonce
	func setNonce(_ nonce: String)

	/// set the stoken
	/// - Parameter stoken: the stoken
	func setStoken(_ stoken: String)

	func generateCommitment() -> String?

	/// Get the stoken
	/// - Returns: the stoken
	func getStoken() -> String?
}

struct IsmRequest: Codable {

	let accessToken: String
	let stoken: String
	let issuerCommitmentMessage: String

	enum CodingKeys: String, CodingKey {

		case accessToken = "access_token"
		case stoken = "stoken"
		case issuerCommitmentMessage = "icm"
	}
}

/// Structure to hold cryptography data
private struct CryptoData: Codable {

	/// The key of the holder
	var holderSecretKey: Data?
	var nonce: String?
	var stoken: String?

	/// Empty crypto data
	static var empty: CryptoData {
		return CryptoData(holderSecretKey: nil, nonce: nil, stoken: nil)
	}
}

/// The cryptography manager
class CryptoManager: CryptoManagerProtocol, Logging {

	/// Array of constants
	private struct Constants {
		static let keychainService = "CryptoManager"
	}

	/// The crypto data stored in the keychain
	@Keychain(name: "cryptoData", service: Constants.keychainService, clearOnReinstall: true)
	private var cryptoData: CryptoData = .empty

	/// The publc key of the issuer
	private var issuerPublicKey: Data?

	/// Initializer
	required init() {

		// Public Key
		if let content = FileReader(bundle: Bundle(for: type(of: self)), fileName: "issuerPk", fileType: "xml").read() {
			issuerPublicKey = content.data(using: .utf8)
		}

		if cryptoData.holderSecretKey == nil {
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

	/// Debug method
	func debug() {

		if let holderSK = cryptoData.holderSecretKey {
			let holderSKString = String(decoding: holderSK, as: UTF8.self)
			self.logDebug("CryptoData:\n holderSK: \(holderSKString)\n nonce: \(cryptoData.nonce ?? "n/a")\n stoken: \(cryptoData.stoken ?? "n/a")")
		}
		if let issuerPK = issuerPublicKey {
			let issuerPublicKeyString = String(decoding: issuerPK, as: UTF8.self)
			self.logDebug("CryptoData:\n issuerPublicKey: \(String(issuerPublicKeyString.prefix(54))))")
		}
	}

	func generateCommitment() -> String? {

		if let nonce = cryptoData.nonce {
			let string = "\(nonce)"
			let nonceData = Data(string.bytes)

			if let result = ClmobileCreateCommitmentMessage(cryptoData.holderSecretKey, issuerPublicKey, nonceData) {
				if result.error.isEmpty {
					if let value = result.value {
						let string = String(decoding: value, as: UTF8.self)
						return string
					}
				} else {
					self.logDebug("ICM: \(result.error)")
				}
			}
		}
		return nil
	}

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
}
