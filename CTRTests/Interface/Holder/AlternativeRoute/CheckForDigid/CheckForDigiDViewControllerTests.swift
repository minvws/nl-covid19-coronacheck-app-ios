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
import TestingShared
import ReusableViews
import Resources

class CheckForDigidViewControllerTests: XCTestCase {

	var sut: CheckForDigidViewController!
	var coordinatorDelegateSpy: AlternativeRouteCoordinatorDelegateSpy!

	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = AlternativeRouteCoordinatorDelegateSpy()
		sut = CheckForDigidViewController(
			viewModel: CheckForDigidViewModel(
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

	func test_requestDidig_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.first as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedOpenUrl) == true
		expect(self.coordinatorDelegateSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holder_noDigiD_url()
	}

	func test_noDigid_tapped() {

		// Given
		loadView()

		// When
		(self.sut.sceneView.optionStackView.arrangedSubviews.last as? DisclosureSubtitleButton)?.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCheckForBSN) == true
	}
}
