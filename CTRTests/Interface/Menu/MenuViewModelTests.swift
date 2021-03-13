/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class MenuViewModelTests: XCTestCase {

	/// Subject under test
	var sut: MenuViewModel?

	/// The coordinator spy
	var menuDelegateSpy = MenuDelegateSpy()

	var appVersionSupplierSpy = AppVersionSupplierSpy(version: "MenuViewModelTests", build: "Test")

	override func setUp() {

		super.setUp()
		menuDelegateSpy = MenuDelegateSpy()
		appVersionSupplierSpy = AppVersionSupplierSpy(version: "MenuViewModelTests", build: "Test")
		sut = MenuViewModel(delegate: menuDelegateSpy, versionSupplier: appVersionSupplierSpy)
	}

	// MARK: - Tests

	/// Test the initializer
	func testInitializer() {

		// Given

		// When
		sut = MenuViewModel(delegate: menuDelegateSpy, versionSupplier: appVersionSupplierSpy)

		// Then
		XCTAssertTrue(menuDelegateSpy.getTopMenuItemsCalled, "Menu should fetch the top menu items")
		XCTAssertTrue(menuDelegateSpy.getBottomMenuItemsCalled, "Menu should fetch the bottom menu items")
		XCTAssertTrue(appVersionSupplierSpy.getCurrentVersionCalled, "Version should be called")
		XCTAssertTrue(appVersionSupplierSpy.getCurrentBuildCalled, "Build should be called")
	}

	/// Test the close menu method
	func testCloseMenu() {

		// Given

		// When
		sut?.clossButtonTapped()

		// Then
		XCTAssertTrue(menuDelegateSpy.closeMenuCalled, "Close Menu delegate method should be called")
	}

	/// Test the close menu method
	func testOpenMenuItem() {

		// Given
		let identifier = MenuIdentifier.about

		// When
		sut?.menuItemTapped(identifier)

		// Then
		XCTAssertTrue(menuDelegateSpy.openMenuItemCalled, "Open Menu Item delegate method should be called")
		XCTAssertEqual(menuDelegateSpy.openMenuItemIdentifier, .about, "Menu Item Identifier should match")
	}
}

class MenuDelegateSpy: MenuDelegate {

	var closeMenuCalled = false
	var openMenuItemCalled = false
	var openMenuItemIdentifier: MenuIdentifier?
	var getTopMenuItemsCalled = false
	var topMenuItems = [MenuItem]()
	var getBottomMenuItemsCalled = false
	var bottomMenuItems = [MenuItem]()

	func closeMenu() {

		closeMenuCalled = true
	}

	func openMenuItem(_ identifier: MenuIdentifier) {

		openMenuItemCalled = true
		openMenuItemIdentifier = identifier
	}

	func getTopMenuItems() -> [MenuItem] {

		getTopMenuItemsCalled = true
		return topMenuItems
	}

	func getBottomMenuItems() -> [MenuItem] {

		getBottomMenuItemsCalled = true
		return bottomMenuItems
	}
}
