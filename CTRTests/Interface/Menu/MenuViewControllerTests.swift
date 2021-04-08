/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class MenuViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: MenuViewController?

	/// The coordinator spy
	var menuDelegateSpy = MenuDelegateSpy()

	var viewModel: MenuViewModel?

	var window = UIWindow()

	override func setUp() {

		super.setUp()

		menuDelegateSpy = MenuDelegateSpy()
		viewModel = MenuViewModel(delegate: menuDelegateSpy)
		sut = MenuViewController(viewModel: viewModel!)
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

	func testTopMenu() {

		// Given
		let items = [MenuItem(identifier: .about, title: "about"), MenuItem(identifier: .faq, title: "faq")]
		loadView()

		// When
		viewModel?.topMenu = items

		// Then
		XCTAssertEqual(sut?.sceneView.topStackView.arrangedSubviews.count, items.count, "There should be two top menu items")
		XCTAssertEqual(sut?.sceneView.bottomStackView.arrangedSubviews.count, 0, "There should be no bottom menu items")
	}

	func testBotomMenu() {

		// Given
		let items = [MenuItem(identifier: .about, title: "about"), MenuItem(identifier: .faq, title: "faq")]
		loadView()

		// When
		viewModel?.bottomMenu = items

		// Then
		XCTAssertEqual(sut?.sceneView.topStackView.arrangedSubviews.count, 0, "There should be no top menu items")
		XCTAssertEqual(sut?.sceneView.bottomStackView.arrangedSubviews.count, items.count, "There should be two bottom menu items")
	}

	func testCloseMenu() {

		// Given
		loadView()

		// When
		sut?.clossButtonTapped()

		// Then
		XCTAssertTrue(menuDelegateSpy.closeMenuCalled, "Close Menu delegate method should be called")
	}

	func testTopMenuItemClicked() {

		// Given
		let items = [MenuItem(identifier: .faq, title: "faq"), MenuItem(identifier: .about, title: "about")]
		loadView()
		viewModel?.topMenu = items

		// When
		(sut?.sceneView.topStackView.arrangedSubviews.first as? MenuItemView)?.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(menuDelegateSpy.openMenuItemCalled, "Open Menu Item delegate method should be called")
		XCTAssertEqual(menuDelegateSpy.openMenuItemIdentifier, .faq, "Menu Item Identifier should match")
	}

	func testBotomMenuItemClicked() {

		// Given
		let items = [MenuItem(identifier: .about, title: "about"), MenuItem(identifier: .faq, title: "faq")]
		loadView()
		viewModel?.bottomMenu = items

		// When
		(sut?.sceneView.bottomStackView.arrangedSubviews.first as? MenuItemView)?.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(menuDelegateSpy.openMenuItemCalled, "Open Menu Item delegate method should be called")
		XCTAssertEqual(menuDelegateSpy.openMenuItemIdentifier, .about, "Menu Item Identifier should match")
	}
}
