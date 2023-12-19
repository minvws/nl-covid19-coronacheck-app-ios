/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import SnapshotTesting
import Shared
@testable import ReusableViews
@testable import Resources

class ErrorViewTests: XCTestCase {

	var sut: ErrorView!
	
	override class func setUp() {
		super.setUp()
		registerFonts()
	}
	
	override func setUp() {
		super.setUp()
		
		sut = ErrorView()
		sut.frame = CGRect(x: 0, y: 0, width: 390, height: 100)
		sut.backgroundColor = C.white()
	}

	func test_singleLine() {

		// Given
		sut.error = "Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: BRB-YYYYYYYYY1-Z2."

		// Then
		assertSnapshot(matching: sut, as: .image)
	}

	func test_multiLine() {

		// Given
		sut.error = "Deze testlocatie is (nog) niet bij ons bekend. Neem contact op met de locatie waar je bent getest."

		// Then
		assertSnapshot(matching: sut, as: .image)
	}
}
