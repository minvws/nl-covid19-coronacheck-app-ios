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
	var sut: AppointmentViewModel?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	/// Configuration spy
	var configurationSpy = ConfigurationGeneralSpy()

	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		configurationSpy = ConfigurationGeneralSpy()
		sut = AppointmentViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			maxValidity: "test",
			configuration: configurationSpy
		)
	}

	// MARK: - Tests

	/// Test the tap on the link
	func testLinkTapped() {

		// Given

		// When
		sut?.linkedTapped()

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
