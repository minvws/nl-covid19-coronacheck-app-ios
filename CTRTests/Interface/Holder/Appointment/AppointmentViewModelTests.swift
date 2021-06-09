/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class AppointmentViewModelTests: XCTestCase {

	/// Subject under test
	var sut: AppointmentViewModel!

	/// The coordinator spy
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = AppointmentViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			maxValidity: 40
		)
	}

	// MARK: - Tests

	/// Test the tap on the link
	func test_openUrl() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut?.openUrl(url)

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.openUrlCalled, "Delegate should be called")
	}

	/// Test the tap on the button
	func testButtonTapped() {

		// Given

		// When
		sut?.buttonTapped()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.openUrlCalled, "Delegate should be called")
	}
}
