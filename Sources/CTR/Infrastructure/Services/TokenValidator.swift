/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import LuhnCheck

public protocol TokenValidatorProtocol {

	/// Validate the token
	/// - Parameters:
	///   - token: the token to validate
	/// - Returns: True if the token is valid
	func validate(_ token: String) -> Bool
}

public class TokenValidator: TokenValidatorProtocol {

	private let luhnCheck: LuhnCheck
	private let allowedCharacterSet: CharacterSet
	private let isLuhnCheckEnabled: Bool

	/// Initializer
	/// - Parameters:
	///   - alphabet: the alphabet to use
	///   - isLuhnCheckEnabled: True if we should use the Luhn Check
	public init(alphabet: String = "BCFGJLQRSTUVXYZ23456789", isLuhnCheckEnabled: Bool ) {

		self.allowedCharacterSet = CharacterSet(charactersIn: alphabet)
		self.isLuhnCheckEnabled = isLuhnCheckEnabled
		self.luhnCheck = LuhnCheck(validTokens: alphabet)
	}

	/// Validate the token
	/// - Parameters:
	///   - token: the token to validate
	/// - Returns: True if the token is valid
	public func validate(_ token: String) -> Bool {

		let codeSplit = token.components(separatedBy: "-")

		// Hard Rules for Token (XXX-YYYYYYYYY-Z2)
		guard codeSplit.count == 3 else {

			return false
		}
		guard codeSplit[0].count == 3 else {

			return false
		}

		guard codeSplit[1].unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) else {

			return false
		}

		guard codeSplit[2].count == 2 else {

			return false
		}

		guard let checksum = codeSplit[2].first, checksum.unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) else {

			return false
		}
		
		guard codeSplit[2].last == "2" else {

			return false
		}

		guard isLuhnCheckEnabled == true else {
			// Skip Luhn check if disabled
			return true
		}
		
		let code = codeSplit[1] + codeSplit[2].prefix(1)
		return luhnCheck.luhnModN(code)
	}
}
