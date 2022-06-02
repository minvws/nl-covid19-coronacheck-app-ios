/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

final class PaperProofIdentifierTests: XCTestCase {
	
	private var sut: PaperProofIdentifier!
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		sut = PaperProofIdentifier()
	}

	func test_hasDomesticPrefix() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedHasDomesticPrefixResult = true
		
		// When
		let result = sut.identify("test")
		
		// Then
		expect(result) == PaperProofType.hasDomesticPrefix
	}
	
	func test_isForeignDCC() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedHasDomesticPrefixResult = false
		environmentSpies.cryptoManagerSpy.stubbedIsForeignDCCResult = true
		environmentSpies.cryptoManagerSpy.stubbedIsDCCResult = true
		
		// When
		let result = sut.identify("test")
		
		// Then
		expect(result) == PaperProofType.foreignDCC(dcc: "test")
	}
	
	func test_isDutchDCC() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedHasDomesticPrefixResult = false
		environmentSpies.cryptoManagerSpy.stubbedIsForeignDCCResult = false
		environmentSpies.cryptoManagerSpy.stubbedIsDCCResult = true
		
		// When
		let result = sut.identify("test")
		
		// Then
		expect(result) == PaperProofType.dutchDCC(dcc: "test")
	}
	
	func test_unknown() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedHasDomesticPrefixResult = false
		environmentSpies.cryptoManagerSpy.stubbedIsForeignDCCResult = false
		environmentSpies.cryptoManagerSpy.stubbedIsDCCResult = false
		
		// When
		let result = sut.identify("test")
		
		// Then
		expect(result) == PaperProofType.unknown
	}
}
