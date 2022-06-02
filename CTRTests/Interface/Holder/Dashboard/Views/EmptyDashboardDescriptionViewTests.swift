/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting

final class EmptyDashboardDescriptionViewTests: XCTestCase {
	
	var sut: EmptyDashboardDescriptionCardView!

	override func setUp() {
		super.setUp()

		sut = EmptyDashboardDescriptionCardView()
		sut.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			sut.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
		])
	}

	func test_domestic() {
		// Arrange
		sut.message = "Je kunt een bewijs toevoegen als je bent gevaccineerd of hersteld. Of als je bent getest bij een aangesloten testlocatie. De app maakt een Nederlands en een internationaal bewijs."

		// Act
		// Assert
		sut.assertImage()
	}
	
	func test_international() {
		// Arrange
		sut.message = """
		Ben je in het buitenland of ga je de grens over? Gebruik dan altijd jouw internationale bewijs. Controleer voor vertrek welk bewijs je nodig hebt.
		
		Welk bewijs is geldig op mijn bestemming?
		"""

		// Act
		// Assert
		sut.assertImage()
	}
}
