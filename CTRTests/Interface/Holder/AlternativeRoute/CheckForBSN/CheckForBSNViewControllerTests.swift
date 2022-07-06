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

class CheckForBSNViewControllerTests: XCTestCase {

	var sut: ListOptionsViewController!
	var coordinatorDelegateSpy: AlternativeRouteCoordinatorDelegateSpy!

	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = AlternativeRouteCoordinatorDelegateSpy()
		sut = ListOptionsViewController(
			viewModel: CheckForBSNViewModel(
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
		loadView()
		sut.assertImage(containedInNavigationController: true)
	}

	func test_withBSN_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.first as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToContactHelpDeksWithBSN) == true
	}

	func test_withoutBSN_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.last as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserHasNoBSN) == true
	}
}
