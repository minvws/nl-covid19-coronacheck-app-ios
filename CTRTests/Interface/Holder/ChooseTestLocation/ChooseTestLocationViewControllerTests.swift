/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
import ReusableViews

class ChooseTestLocationViewControllerTests: XCTestCase {

	var sut: ListOptionsViewController!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = ListOptionsViewController(
			viewModel: ChooseTestLocationViewModel(
				coordinator: coordinatorDelegateSpy
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

	func test_notTestedButton_tapped() {

		// Given
		loadView()

		// When
		self.sut.sceneView.secondaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInfoAboutGettingTested) == true
	}

	func test_ggdbutton_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.first as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateANegativeTestQRFromGGD) == true
	}

	func test_otherbutton_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.last as? DisclosureButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateANegativeTestQR) == true
	}
}
