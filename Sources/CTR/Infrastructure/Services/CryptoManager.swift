/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Ctcl

protocol CryptoManagerProtocol {

	init()

	func debug()
}

/// Structure to hold cryptography data
private struct CryptoData: Codable {

	/// The key of the holder
	var holderSK: Data?

	/// Empty crypto data
	static var empty: CryptoData {
		return CryptoData(holderSK: nil)
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
	// swiftlint:disable:previous let_var_whitespace

	/// Initializer
	required init() {

		if cryptoData.holderSK == nil {
			self.cryptoData = CryptoData(
				holderSK: JsoninterfaceGenerateHolderSk()
			)
		}
	}

	/// Debug method
	func debug() {

		if let holderSK = cryptoData.holderSK {
			let holderSKString = String(decoding: holderSK, as: UTF8.self)
			self.logDebug("CryptoData: \(holderSKString)")
		}
	}
}
