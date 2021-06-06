//
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

final class MakeTestAppointmentViewTests: XCTestCase {
	
	var sut: MakeTestAppointmentView!
	
	override func setUp() {
		super.setUp()
		
		sut = MakeTestAppointmentView(
			frame: CGRect(
				origin: .zero,
				size: CGSize(
					width: UIScreen.main.bounds.width,
					height: 200
				)
			)
		)
	}
	
	func test_snapshot() {
		
		// Given
		sut.title = "Here is the title"
		sut.buttonTitle = "Make an appointment"
		sut.message = "Here is the message"

		// Then
		assertSnapshot(matching: sut, as: .image(precision: 0.9))
	}
}
