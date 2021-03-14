/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol TokenValidatorProtocol {

	/// Validate the token
	/// - Parameters:
	///   - token: the token to validate
	/// - Returns: True if the token is valid
	func validate(_ token: String) -> Bool
}

class TokenValidator: TokenValidatorProtocol {

	private let tokenChars: [String.Element]

	/// Initialize
	/// - Parameter alphabet: the alphabet to use
	init(alphabet: String = "BCFGJLQRSTUVXYZ23456789") {

		tokenChars = Array(alphabet)
	}

	/// Validate the token
	/// - Parameters:
	///   - token: the token to validate
	/// - Returns: True if the token is valid
	func validate(_ token: String) -> Bool {

		let codeSplit = token.components(separatedBy: "-")

		guard codeSplit.count == 3 else {
			return false
		}

		let code = codeSplit[1] + codeSplit[2].prefix(1)
		return luhnModN(code)
	}

	/// Check the luhn mod N checksum
	/// - Parameter token: the token to check
	/// - Returns: True if this is a valid token
	private func luhnModN(_ token: String) -> Bool {

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
