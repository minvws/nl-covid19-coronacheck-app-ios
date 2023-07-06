/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import XCTest
@testable import CTR
import SnapshotTesting
import TestingShared

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
	
	func test_international() {
		// Arrange
		sut.title = "Hier komt jouw internationale bewijs"
		sut.image = I.dashboard.international()

		// Act
		// Assert
		sut.assertImage()
	}
}
