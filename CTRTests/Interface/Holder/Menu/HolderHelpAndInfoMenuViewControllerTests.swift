/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
import SnapshotTesting
import Shared
import TestingShared
@testable import Resources
@testable import Managers

class HolderHelpAndInfoMenuViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: MenuViewController!
	private var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {
		
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = MenuViewController(viewModel: HolderHelpAndInfoMenuViewModel(coordinatorDelegateSpy))
		
		window = UIWindow()
		super.setUp()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_content() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.holder_helpInfo_title()
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_openFAQ() {

		// Given
		loadView()

		// When
		(sut.sceneView.stackView.arrangedSubviews[0] as? MenuRowView)?.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_userWishesToSeeHelpdesk() {

		// Given
		loadView()

		// When
		(sut.sceneView.stackView.arrangedSubviews[1] as? MenuRowView)?.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeHelpdesk) == true
	}
	
	func test_userWishesToSeeAboutThisApp() {

		// Given
		loadView()

		// When
		(sut.sceneView.stackView.arrangedSubviews[3] as? MenuRowView)?.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeAboutThisApp) == true
	}
}
