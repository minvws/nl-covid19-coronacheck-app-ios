/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
import SnapshotTesting

class ChooseTestLocationViewTests: XCTestCase {

	var sut: ChooseTestLocationView!

	override func setUp() {
		super.setUp()

		sut = ChooseTestLocationView(frame: UIScreen.main.bounds)
	}

	func test_() {
		// Arrange
		sut.title = "Here is the title"
		sut.message = "Here is a message"

		// Act

		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
}
