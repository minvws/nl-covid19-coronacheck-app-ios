/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class AppointmentViewControllerTests: XCTestCase {

	/// Subject under test
	private var sut: AppointmentViewController!

	private var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	private var viewModel: AppointmentViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		viewModel = AppointmentViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			maxValidity: "test"
		)
		sut = AppointmentViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	/// Test the tap on the button
	func testButtonTapped() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.holderCoordinatorDelegateSpy.openUrlCalled) == true
	}
}
