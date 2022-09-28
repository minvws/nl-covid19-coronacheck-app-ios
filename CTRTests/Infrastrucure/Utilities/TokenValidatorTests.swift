/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble

class TokenValidatorTests: XCTestCase {

	var sut = TokenValidator(isLuhnCheckEnabled: true)

	override func setUp() {

		super.setUp()

		sut = TokenValidator(isLuhnCheckEnabled: true)
	}

	// MARK: - Tests

	/// Test the validator with valid tokens
	func test_validator_withValidTokens() {

		// Given
		let validTokens: [String] = [
			"ZZZ-2SX4XLGGXUB6V9-42",
			"ZZZ-YL8BSX9T6J39C7-Q2",
			"ZZZ-2FR36XSUGJY3UZ-G2",
			"ZZZ-32X4RUBC2TYBX6-U2",
			"FLA-SGF25J4TBT-X2",
			"FLA-4RRT5FRQ6L-X2",
			"FLA-QGJ6Y2SBSY-62"
		]

		for token in validTokens {

			// When
			let result = sut.validate(token)

			// Then
			expect(result) == true
		}
	}

	/// Test the validator with invalid tokens
	func test_validator_withInvalidTokens() {

		// Given
		let invalidTokens: [String] = [
			"ZZZ-2SX4XLGGXUB6V8-42",
			"ZZZ-YL8BSX9T6J39C7-L2",
			"FLA-SGF25J4TBT-Y2",
			"FLA-4RRT5FRQ6L",
			"FLA",
			"",
			"T-E-S-T",
			"T--T",
			"ZZZ-AAAAA-A2",
			"ZZZ-32X4RUBC2TYBX6-UU2",
			"ZZZ-32X4RUBC2TYBX6-U3",
			"ZZZ-AA-B2",
			"ZZZ-BB-A2"
		]

		for token in invalidTokens {

			// When
			let result = sut.validate(token)

			// Then
			expect(result) == false
		}
	}

	func test_luhnNChecksum_withValidTokens() {

		// Given
		let validTokens: [String] = [
			"2SX4XLGGXUB6V94",
			"YL8BSX9T6J39C7Q",
			"2FR36XSUGJY3UZG",
			"32X4RUBC2TYBX6U",
			"SGF25J4TBTX",
			"4RRT5FRQ6LX",
			"QGJ6Y2SBSY6"
		]

		for token in validTokens {

			// When
			let result = sut.luhnModN(token)

			// Then
			expect(result) == true
		}
	}

	func test_luhnNChecksum_withInvalidTokens() {

		// Given
		let validTokens: [String] = [
			"2SX4XLGGXUB6V84",
			"YL8BSX9T6J39C7L",
			"SGF25J4TBTY"
		]

		for token in validTokens {

			// When
			let result = sut.luhnModN(token)

			// Then
			expect(result) == false
		}
	}

	func test_luhnNChecksum_withInvalidChars() {

		// Given
		let validTokens: [String] = [
			"2SPW782",
			"SGF25J4TBTA"
		]

		for token in validTokens {

			// When
			let result = sut.luhnModN(token)

			// Then
			expect(result) == false
		}
	}
	
	/// Test the validator with invalid tokens and Luhn check disabled
	func test_validator_whenLuhnCheckIsDisabled_withInvalidTokens() {

		// Given
		let sut = TokenValidator(isLuhnCheckEnabled: false)
		
		let invalidTokens: [String] = [
			"ZZZ-5343CQ2BJ3UV7X-Z2",
			"ZZZ-Q343CQ2BJ3UV7X-Q2"
		]

		for token in invalidTokens {

			// When
			let result = sut.validate(token)

			// Then
			expect(result) == true
		}
	}
	
	/// Test the validator with invalid tokens and Luhn check enabled
	func test_validator_whenLuhnCheckIsEnabled_withInvalidTokens() {

		// Given
		let sut = TokenValidator(isLuhnCheckEnabled: true)
		
		let invalidTokens: [String] = [
			"ZZZ-5343CQ2BJ3UV7X-Z2",
			"ZZZ-Q343CQ2BJ3UV7X-Q2"
		]

		for token in invalidTokens {

			// When
			let result = sut.validate(token)

			// Then
			expect(result) == false
		}
	}
}
