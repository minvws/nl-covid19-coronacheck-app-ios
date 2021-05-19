/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

class AboutMakingAQRViewControllerTests: XCTestCase {

	var sut: AboutMakingAQRViewController!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = AboutMakingAQRViewController(viewModel: AboutMakingAQRViewModel(
			coordinator: coordinatorDelegateSpy
		))
	}

	func test_snapshot() {

		assertSnapshot(matching: sut, as: .image(precision: 0.9))
	}
}
