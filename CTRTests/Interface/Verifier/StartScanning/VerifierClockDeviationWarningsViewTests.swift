/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
@testable import CTR

class VerifierClockDeviationWarningsViewTests: XCTestCase {

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
