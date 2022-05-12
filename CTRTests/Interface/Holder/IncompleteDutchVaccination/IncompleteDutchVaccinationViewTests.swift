/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import SnapshotTesting
@testable import CTR

class IncompleteDutchVaccinationViewTests: XCTestCase {

	var sut: IncompleteDutchVaccinationView!

	override func setUp() {
		super.setUp()

		sut = IncompleteDutchVaccinationView()
		sut.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
	}

	func testLabels() {
		sut.title = "title"
		sut.secondVaccineText = "secondVaccineText"
		sut.assertImage()
	}
}
