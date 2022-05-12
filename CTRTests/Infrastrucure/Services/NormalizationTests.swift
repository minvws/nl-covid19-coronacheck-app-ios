/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class NormalizationTests: XCTestCase {

	func test_normalization() {

		// Given
		let values: [String: String] = [
			"Rool": "rool",
			"#$pietje": "pietje",
			"παράδειγμα δοκιμής": "paradeigma dokimes",
			"Ægir": "aegir",
			"'Doorn": "doorn",
			"Özturk": "ozturk",
			"ТЕСТ МИЛИЦА": "test milica",
			"Şımarık": "simarik",
			"王": "wang",
			"Ådne": "adne",
			"محمود عبدالرحيم": "mhmwd bdalrhym",
			"أحمد‎": "ahmd"
		]

		for (value, expected) in values {

			// When
			let normalized = Normalizer.normalize(value)

			// Then
			expect(normalized) == expected
		}
	}

	func test_azInitial() {

		// Given
		let values: [String: String?] = [
			"": nil,
			"Rool": "R",
			" Rool": "R",
			"-de Vries": "D",
			"#$pietje": nil,
			"παράδειγμα δοκιμής": nil,
			"Ægir": nil,
			"'Doorn": "D",
			"Özturk": nil,
			"ТЕСТ МИЛИЦА": nil,
			"Şımarık": nil,
			"王": nil,
			"Ådne": nil,
			"محمود عبدالرحيم": nil,
			"أحمد‎": nil
		]

		for (value, expected) in values {

			// When
			let normalized = Normalizer.toAzInitial(value)

			// Then
			if expected == nil {
				expect(normalized).to(beNil())
			} else {
			expect(normalized) == expected
			}
		}
	}
}
