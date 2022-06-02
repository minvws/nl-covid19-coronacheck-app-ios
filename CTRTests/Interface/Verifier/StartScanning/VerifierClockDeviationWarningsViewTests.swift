/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import SnapshotTesting
@testable import CTR
import XCTest

class VerifierClockDeviationWarningsViewTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	func testDefaultRendering() {

		// Arrange
		let sut = VerifierClockDeviationWarningView()
		sut.buttonTitle = "Here is a button"
		sut.message = "Here is the message"

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 335, height: 144)
		sut.assertImage()
	}
}
