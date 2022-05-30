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

class VerifierStartScanningViewTests: XCTestCase {
	var sut: VerifierStartScanningView!

	override func setUp() {
		super.setUp()
		sut = VerifierStartScanningView()
	}

	func test_headerImage() {
		// Arrange
		sut.headerMode = .image(I.scanner.scanStart3GPolicy()!)
		
		// Act

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 400, height: 700)
		assertSnapshot(matching: sut, as: .image(precision: 0.98))
	}

	func test_headerAnimation() {
		// Arrange
		sut.headerMode = .animation("switch_to_blue_animation")
		
		// Act

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 400, height: 700)
		assertSnapshot(matching: sut, as: .image)
	}

	func test_headerHidden() {
		// Arrange
		sut.headerMode = .image(I.scanner.scanStart3GPolicy()!)
		
		// Act
		sut.hideHeader()

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 400, height: 700)
		assertSnapshot(matching: sut, as: .image)
		
		// Act 2
		sut.showHeader()
		
		// Assert2
		assertSnapshot(matching: sut, as: .image(precision: 0.98))
	}
}
