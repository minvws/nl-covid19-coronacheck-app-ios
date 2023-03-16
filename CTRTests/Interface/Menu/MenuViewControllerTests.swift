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

class MenuViewControllerTests: XCTestCase {
	
	private class TestMenuViewModel: MenuViewModelProtocol {
		
		var title = Shared.Observable(value: "")
		var items = Shared.Observable<[Item]>(value: [])
		
		init(title: String = L.general_menu(), items: [Item]) {
			self.title.value = title
			self.items.value = items
		}
	}
	
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
			viewModel: TestMenuViewModel(
				items: [
					TestMenuViewModel.Item.row(title: "test_singleItem", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { })
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
			viewModel: TestMenuViewModel(
				items: [
					TestMenuViewModel.Item.row(title: "test_singleItem", subTitle: "subTitle", icon: I.icon_menu_add()!, overrideColor: nil, action: { })
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
			viewModel: TestMenuViewModel(
				items: [
					TestMenuViewModel.Item.row(title: "first item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { }),
					TestMenuViewModel.Item.row(title: "second item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { })
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
			viewModel: TestMenuViewModel(
				items: [
					TestMenuViewModel.Item.row(title: "first item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { }),
					TestMenuViewModel.Item.sectionBreak,
					TestMenuViewModel.Item.row(title: "second item", subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil, action: { })
				]
			)
		)
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
}
