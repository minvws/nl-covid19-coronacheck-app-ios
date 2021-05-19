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

class AboutMakingAQRViewTests: XCTestCase {
	var sut: AboutMakingAQRView!

	override func setUp() {
		super.setUp()

		sut = AboutMakingAQRView(frame: UIScreen.main.bounds)
	}

	func test_() {
		// Arrange
		sut.body = "Here is the body"
		sut.buttonTitle = "Button Title"
		sut.header = "The header"

		// Act

		// Assert
		assertSnapshot(matching: sut, as: .image(precision: 0.9))
	}
}
