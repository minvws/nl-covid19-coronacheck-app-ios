/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class AppointmentViewControllerTests: XCTestCase {

	/// Subject under test
	var sut: AppointmentViewController?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	/// Configuration spy
	var configurationSpy = ConfigurationGeneralSpy()

	/// The view model
	var viewModel: AppointmentViewModel?

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		configurationSpy = ConfigurationGeneralSpy()

		viewModel = AppointmentViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			maxValidity: "test",
			configuration: configurationSpy
		)
		sut = AppointmentViewController(viewModel: viewModel!)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		if let sut = sut {
			window.addSubview(sut.view)
			RunLoop.current.run(until: Date())
		}
	}

	// MARK: - Tests

	/// Test the tap on the button
	func testButtonTapped() {

		// Given
		loadView()

		// When
		sut?.sceneView.primaryButtonTapped()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.openUrlCalled, "Delegate should be called")
	}
}
