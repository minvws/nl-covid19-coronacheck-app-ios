/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

// swiftlint:disable type_name
class MigrationTransferOptionsViewControllerTests: XCTestCase {

	var sut: ListOptionsViewController!
	var coordinatorDelegateSpy: MigrationCoordinatorDelegateSpy!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = MigrationCoordinatorDelegateSpy()
		sut = ListOptionsViewController(
			viewModel: MigrationTransferOptionsViewModel(
				coordinatorDelegateSpy
			)
		)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	func test_snapshot() {
		sut.assertImage()
	}

	func test_toOtherDevice_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.first as? DisclosureLeadingImageButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeToOtherDeviceInstructions) == true
	}

	func test_toThisDevice_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews[1] as? DisclosureLeadingImageButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeToThisDeviceInstructions) == true
	}

}
