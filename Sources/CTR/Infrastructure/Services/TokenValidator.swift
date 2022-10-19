/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport

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
	public init( alphabet: String = "BCFGJLQRSTUVXYZ23456789", isLuhnCheckEnabled: Bool ) {

		self.allowedCharacterSet = CharacterSet(charactersIn: alphabet)
		self.isLuhnCheckEnabled = isLuhnCheckEnabled
		self.luhnCheck = LuhnCheck(alphabet: alphabet)
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

extension RequestToken {
	
	public init?(input: String, tokenValidator: TokenValidatorProtocol) {
		// Check the validity of the input
		guard tokenValidator.validate(input) else {
			return nil
		}
		
		let parts = input.split(separator: "-")
		guard parts.count >= 2, parts[0].count == 3 else { return nil }
		
		let identifierPart = String(parts[0])
		let tokenPart = String(parts[1])
		self = RequestToken(
			token: tokenPart,
			protocolVersion: type(of: self).highestKnownProtocolVersion,
			providerIdentifier: identifierPart
		)
	}
}

class LuhnCheck {
	
	private let tokenChars: [String.Element]

	/// Initializer
	/// - Parameters:
	///   - alphabet: the alphabet to use
	public init(alphabet: String = "BCFGJLQRSTUVXYZ23456789" ) {

		self.tokenChars = Array(alphabet)
	}
	
	/// Check the luhn mod N checksum
	/// - Parameter token: the token to check
	/// - Returns: True if this is a valid token
	func luhnModN(_ token: String) -> Bool {

		// for more detail,
		// see https://en.wikipedia.org/wiki/Luhn_mod_N_algorithm

		let tokenArray = Array(token)
		var factor = 1
		var sum = 0
		let numberOfValidInputCharacters = tokenChars.count
		var index = token.count - 1
		while index >= 0 {
			guard let codePoint = tokenChars.firstIndex(of: tokenArray[index]) else {
				// codePoint not in tokenChars. Fail.
				return false
			}
			var addend = factor * codePoint
			factor = (factor == 2) ? 1 : 2
			addend = (addend / numberOfValidInputCharacters) + (addend % numberOfValidInputCharacters)
			sum += addend
			index -= 1
		}
		let remainder = sum % numberOfValidInputCharacters
		return (remainder == 0)
	}
}
