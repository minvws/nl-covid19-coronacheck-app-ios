/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import TestingShared

final class DashboardTabBarTests: XCTestCase {
	
	var sut: DashboardTabBar!

	override func setUp() {
		super.setUp()

		sut = DashboardTabBar()
		sut.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			sut.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
		])
	}
	
	func test_domestic() {
		// Act
		sut.select(tab: .domestic, animated: false)
		
		// Assert
		sut.assertImage()
	}
	
	func test_international() {
		// Act
		sut.select(tab: .international, animated: false)
		
		// Assert
		sut.assertImage()
	}
}
