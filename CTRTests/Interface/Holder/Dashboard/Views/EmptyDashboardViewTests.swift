/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting

final class EmptyDashboardViewTests: XCTestCase {
	
	var sut: EmptyDashboardView!

	override func setUp() {
		super.setUp()

		sut = EmptyDashboardView()
		sut.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			sut.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
		])
	}

	func test_() {
		// Arrange
		sut.title = "Hier komt jouw bewijs"
		sut.image = .emptyDashboard
		sut.message = "<p>Je kunt een bewijs toevoegen als je bent gevaccineerd of hersteld. Of als je bent getest bij een <a href=\"https://coronacheck.nl/nl/testafspraak-in-app\">aangesloten testlocatie</a>. De app maakt een Nederlands en een internationaal bewijs.</p><b>Reis je buiten Nederland?</b><p>Check <a href=\"www.nederlandwereldwijd.nl/reizen/reisadviezen\">wijsopreis.nl</a> voor vertrek. Daar staat welk bewijs geldig is in het land dat je bezoekt.</p>"

		// Act
		// Assert
		assertSnapshot(matching: sut, as: .image(precision: 0.9))
	}
}
