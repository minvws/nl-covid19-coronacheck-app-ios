/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

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
