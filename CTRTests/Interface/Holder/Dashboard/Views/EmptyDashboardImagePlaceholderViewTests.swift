/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting

final class EmptyDashboardImagePlaceholderViewTests: XCTestCase {
	
	var sut: EmptyDashboardImagePlaceholderCardView!

	override func setUp() {
		super.setUp()

		sut = EmptyDashboardImagePlaceholderCardView()
		sut.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			sut.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
		])
	}

	func test_domestic() {
		// Arrange
		sut.title = "Hier komt jouw Nederlandse bewijs"
		sut.image = I.dashboard.domestic()

		// Act
		// Assert
		sut.assertImage()
	}
	
	func test_international() {
		// Arrange
		sut.title = "Hier komt jouw internationale bewijs"
		sut.image = I.dashboard.international()

		// Act
		// Assert
		sut.assertImage()
	}
}
