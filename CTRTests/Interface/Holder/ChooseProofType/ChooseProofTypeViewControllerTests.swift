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

class ChooseProofTypeViewControllerTests: XCTestCase {

	var sut: ChooseProofTypeViewController!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = ChooseProofTypeViewController(
			viewModel: ChooseProofTypeViewModel(
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

	func test_vaccination_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.buttonsStackView.arrangedSubviews.first as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateAVaccinationQR) == true
	}

	func test_recovery_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.buttonsStackView.arrangedSubviews[1] as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateARecoveryQR) == true
	}

	func test_test_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.buttonsStackView.arrangedSubviews[2] as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToChooseTestLocation) == true
	}
}
