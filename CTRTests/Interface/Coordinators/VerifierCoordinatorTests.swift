/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifierCoordinatorTests: XCTestCase {

	var sut: VerifierCoordinator?

	var navigationSpy = NavigationControllerSpy()

	var window = UIWindow()

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		sut = VerifierCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests

	func testOpenMenuItem() throws {

		// Given
		let strongSut = try XCTUnwrap(sut)
		let menu = MenuViewController(
			viewModel: MenuViewModel(
				delegate: strongSut,
				versionSupplier: AppVersionSupplier()
			)
		)
		sut?.sidePanel = CustomSidePanelController(sideController: UINavigationController(rootViewController: menu))

		let viewControllerSpy = ViewControllerSpy()
		sut?.sidePanel?.selectedViewController = viewControllerSpy

		// When
		sut?.openMenuItem(.privacy)

		// Then
		XCTAssertTrue(viewControllerSpy.presentCalled, "Method should be called")
	}
}
