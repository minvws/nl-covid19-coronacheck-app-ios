/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class MenuViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: MenuViewController!

	/// The coordinator spy
	var menuDelegateSpy = MenuDelegateSpy()

	var viewModel: MenuViewModel!

	var window = UIWindow()

	override func setUp() {

		super.setUp()

		menuDelegateSpy = MenuDelegateSpy()
		viewModel = MenuViewModel(delegate: menuDelegateSpy)
		sut = MenuViewController(viewModel: viewModel)
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func testTopMenu() {

		// Given
		let items = [MenuItem(identifier: .about, title: "about"), MenuItem(identifier: .faq, title: "faq")]
		loadView()

		// When
		viewModel.topMenu = items

		// Then
		expect(self.sut.sceneView.topStackView.arrangedSubviews).to(haveCount(items.count))
		expect(self.sut.sceneView.bottomStackView.arrangedSubviews).to(beEmpty())
	}

	func testBotomMenu() {

		// Given
		let items = [MenuItem(identifier: .about, title: "about"), MenuItem(identifier: .faq, title: "faq")]
		loadView()

		// When
		viewModel.bottomMenu = items

		// Then
		expect(self.sut.sceneView.bottomStackView.arrangedSubviews).to(haveCount(items.count))
		expect(self.sut.sceneView.topStackView.arrangedSubviews).to(beEmpty())
	}

	func testCloseMenu() {

		// Given
		loadView()

		// When
		sut.closeButtonTapped()

		// Then
		expect(self.menuDelegateSpy.invokedCloseMenu) == true
	}

	func testTopMenuItemClicked() {

		// Given
		let items = [MenuItem(identifier: .faq, title: "faq"), MenuItem(identifier: .about, title: "about")]
		loadView()
		viewModel.topMenu = items

		// When
		(sut.sceneView.topStackView.arrangedSubviews.first as? MenuItemView)?.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.menuDelegateSpy.invokedOpenMenuItem) == true
		expect(self.menuDelegateSpy.invokedOpenMenuItemParameters?.0) == .faq
	}

	func testBotomMenuItemClicked() {

		// Given
		let items = [MenuItem(identifier: .about, title: "about"), MenuItem(identifier: .faq, title: "faq")]
		loadView()
		viewModel.bottomMenu = items

		// When
		(sut.sceneView.bottomStackView.arrangedSubviews.first as? MenuItemView)?.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.menuDelegateSpy.invokedOpenMenuItem) == true
		expect(self.menuDelegateSpy.invokedOpenMenuItemParameters?.0) == .about
	}
}
