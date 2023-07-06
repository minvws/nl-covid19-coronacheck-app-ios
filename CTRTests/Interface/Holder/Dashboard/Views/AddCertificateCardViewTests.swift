/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import SnapshotTesting
@testable import CTR
import XCTest

class AddCertificateCardViewTests: XCTestCase {

	func testThreeRowSampleContent() {
		// Arrange
		let sut = AddCertificateCardView()
		sut.title = L.holder_dashboard_addCard_title()
		
		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage(precision: 0.98)
	}
}
