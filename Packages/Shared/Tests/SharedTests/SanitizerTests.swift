/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
import Shared

final class SanitizerTests: XCTestCase {

	func test_sanitizer_tagsInInput_tagsShouldBeStripped() {
		
		// Given
		let input = "<b>Rolus</b>"

		// When
		let result = Sanitizer.sanitize(input)
		
		// Then
		expect(result) == "Rolus"
	}
	
	func test_sanitizer_onlyTags_shouldReturnEmptyString() {
		
		// Given
		let input = "<b></b>"

		// When
		let result = Sanitizer.sanitize(input)
		
		// Then
		expect(result) == ""
	}

	func test_strip_onlyTags_shouldReturnEmptyString() {
		
		// Given
		let input = "<b></b>"

		// When
		let result = Sanitizer.strip(input)
		
		// Then
		expect(result) == ""
	}
}
