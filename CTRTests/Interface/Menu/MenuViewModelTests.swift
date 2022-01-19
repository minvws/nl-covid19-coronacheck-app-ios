/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class MenuViewModelTests: XCTestCase {

	/// Subject under test
	var sut: MenuViewModel!

	/// The coordinator spy
	var menuDelegateSpy = MenuDelegateSpy()

	override func setUp() {

		super.setUp()
		menuDelegateSpy = MenuDelegateSpy()
		sut = MenuViewModel(delegate: menuDelegateSpy)
	}

	// MARK: - Tests

	/// Test the initializer
	func testInitializer() {

		// Given

		// When
		sut = MenuViewModel(delegate: menuDelegateSpy)

		// Then
		expect(self.menuDelegateSpy.invokedGetTopMenuItems) == true
		expect(self.menuDelegateSpy.invokedGetBottomMenuItems) == true
	}

	/// Test the close menu method
	func testCloseMenu() {

		// Given

		// When
		sut.closeButtonTapped()

		// Then
		expect(self.menuDelegateSpy.invokedCloseMenu) == true
	}

	/// Test the close menu method
	func testOpenMenuItem() {

		// Given
		let identifier = MenuIdentifier.about

		// When
		sut.menuItemTapped(identifier)

		// Then
		expect(self.menuDelegateSpy.invokedOpenMenuItem) == true
		expect(self.menuDelegateSpy.invokedOpenMenuItemParameters?.0) == identifier
	}
}

class MenuDelegateSpy: MenuDelegate {

	var invokedCloseMenu = false
	var invokedCloseMenuCount = 0

	func closeMenu() {
		invokedCloseMenu = true
		invokedCloseMenuCount += 1
	}

	var invokedOpenMenuItem = false
	var invokedOpenMenuItemCount = 0
	var invokedOpenMenuItemParameters: (identifier: MenuIdentifier, Void)?
	var invokedOpenMenuItemParametersList = [(identifier: MenuIdentifier, Void)]()

	func openMenuItem(_ identifier: MenuIdentifier) {
		invokedOpenMenuItem = true
		invokedOpenMenuItemCount += 1
		invokedOpenMenuItemParameters = (identifier, ())
		invokedOpenMenuItemParametersList.append((identifier, ()))
	}

	var invokedGetTopMenuItems = false
	var invokedGetTopMenuItemsCount = 0
	var stubbedGetTopMenuItemsResult: [MenuItem]! = []

	func getTopMenuItems() -> [MenuItem] {
		invokedGetTopMenuItems = true
		invokedGetTopMenuItemsCount += 1
		return stubbedGetTopMenuItemsResult
	}

	var invokedGetBottomMenuItems = false
	var invokedGetBottomMenuItemsCount = 0
	var stubbedGetBottomMenuItemsResult: [MenuItem]! = []

	func getBottomMenuItems() -> [MenuItem] {
		invokedGetBottomMenuItems = true
		invokedGetBottomMenuItemsCount += 1
		return stubbedGetBottomMenuItemsResult
	}
}
