/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
import SnapshotTesting

class ListOptionsViewTests: XCTestCase {
	var sut: ListOptionsView!

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