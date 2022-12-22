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

class MenuViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: MenuViewController!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {
		
		window = UIWindow()
		super.setUp()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_singleItem() {
		
		// Given
		sut = MenuViewController(
			viewModel: MenuViewModel(
				items: [
					MenuViewModel.Item.row(title: "test_singleItem", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { })
				]
			)
		)
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_singleItem_subTitle() {
		
		// Given
		sut = MenuViewController(
			viewModel: MenuViewModel(
				items: [
					MenuViewModel.Item.row(title: "test_singleItem", subTitle: "subTitle", icon: I.icon_menu_add()!, overrideColor: nil, action: { })
				]
			)
		)
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}

	func test_twoItems() {
		
		// Given
		sut = MenuViewController(
			viewModel: MenuViewModel(
				items: [
					MenuViewModel.Item.row(title: "first item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { }),
					MenuViewModel.Item.row(title: "second item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { })
				]
			)
		)
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_twoItems_separated() {
		
		// Given
		sut = MenuViewController(
			viewModel: MenuViewModel(
				items: [
					MenuViewModel.Item.row(title: "first item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { }),
					MenuViewModel.Item.sectionBreak,
					MenuViewModel.Item.row(title: "second item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { })
				]
			)
		)
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
}
