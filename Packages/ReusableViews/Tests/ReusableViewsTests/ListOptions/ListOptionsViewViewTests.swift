/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
import Shared
@testable import ReusableViews
@testable import Resources

class ListOptionsViewTests: XCTestCase {
	var sut: ListOptionsView!

	override class func setUp() {
		super.setUp()
		registerFonts()
	}
	
	override func setUp() {
		super.setUp()

		sut = ListOptionsView(frame: UIScreen.main.bounds)
	}

	func test_snapshot() {
		// Arrange
		sut.title = "Here is the title"
		sut.message = "Here is a message"

		// Act

		// Assert
		assertSnapshot(matching: sut, as: .image)
	}

}
