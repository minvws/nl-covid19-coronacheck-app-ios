/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import SnapshotTesting
@testable import CTR
import XCTest
import Nimble

class NewMenuRowViewTests: XCTestCase {
	
	func testStandard() {
		// Arrange
		let sut = NewMenuRowView()
		sut.title = "Small title"
		sut.icon = I.icon_menu_faq()
		
		// Act
		sut.frame = CGRect(x: 0, y: 0, width: 380, height: 90)

		// Assert
		sut.assertImage(precision: 0.98)
	}

	func testLongTitle() {
		// Arrange
		let sut = NewMenuRowView()
		sut.title = "Here is a long title with a very very very long length"
		sut.icon = I.icon_menu_faq()
		
		// Act
		sut.frame = CGRect(x: 0, y: 0, width: 380, height: 140)

		// Assert
		sut.assertImage(precision: 0.98)
	}
	
	func testAction() {
		// Arrange
		let sut = NewMenuRowView()
		
		var triggered = false
		sut.action = {
			triggered = true
		}
		
		// Act
		sut.sendActions(for: .touchUpInside)
		
		// Assert
		expect(triggered) == true
	}
}
