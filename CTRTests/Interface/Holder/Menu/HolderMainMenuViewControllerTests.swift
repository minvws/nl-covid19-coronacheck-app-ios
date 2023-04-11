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

class HolderMainMenuViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: MenuViewController!
	private var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {
		
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.featureFlagManagerSpy.stubbedIsVisitorPassEnabledResult = true
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = MenuViewController(viewModel: HolderMainMenuViewModel(coordinatorDelegateSpy))
		
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
		expect(self.sut.title) == L.general_menu()
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_userWishesToCreateAQR() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.stackView.arrangedSubviews[0] as? MenuRowView)?.sendActions(for: .touchUpInside)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateAQR) == true
	}
	
	func test_userWishesToAddPaperProof() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.stackView.arrangedSubviews[1] as? MenuRowView)?.sendActions(for: .touchUpInside)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToAddPaperProof) == true
	}
	
	func test_userWishesToSeeStoredEvents() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.stackView.arrangedSubviews[3] as? MenuRowView)?.sendActions(for: .touchUpInside)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeStoredEvents) == true
	}
	
	func test_userWishesToSeeHelpAndInfoMenu() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.stackView.arrangedSubviews[4] as? MenuRowView)?.sendActions(for: .touchUpInside)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeHelpAndInfoMenu) == true
	}
	
	func test_userWishesToRestart() {
		
		// Given
		loadView()
		
		// When
		(sut.sceneView.stackView.arrangedSubviews[6] as? MenuRowView)?.sendActions(for: .touchUpInside)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToRestart) == true
	}
}
