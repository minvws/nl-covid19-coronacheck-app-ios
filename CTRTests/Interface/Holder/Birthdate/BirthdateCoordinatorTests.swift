/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class BirthdateCoordinatorTests: XCTestCase {

	var sut: BirthdateCoordinator?
	var navigationSpy = NavigationControllerSpy()
	var viewControllerSpy = ViewControllerSpy()
	var birthdateSceneDelegateSpy = BirthdateSceneDelegateSpy()

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		viewControllerSpy = ViewControllerSpy()
		birthdateSceneDelegateSpy = BirthdateSceneDelegateSpy()

		sut = BirthdateCoordinator(
			navigationController: navigationSpy,
			presentingViewController: viewControllerSpy,
			birthdateSceneDelegate: birthdateSceneDelegateSpy)
	}

	// MARK: Test Doubles

	class BirthdateSceneDelegateSpy: BirthdateSceneDelegate {

		var birthdateConfirmedCalled = false

		func birthdateConfirmed() {
			birthdateConfirmedCalled = true
		}
	}

	// MARK: Tests

	func testStart() {

		// Given

		// When
		sut?.start()

		// Then
		XCTAssertTrue(viewControllerSpy.presentCalled, "Delegate method must be called")
		XCTAssertTrue(viewControllerSpy.thePresentedViewController is UINavigationController, "Type should match")
		XCTAssertTrue((viewControllerSpy.thePresentedViewController as? UINavigationController)?
						.viewControllers.first is BirthdateEntryViewController, "Type should match")
	}

	func testNavigateToBirthdayEntry() {

		// Given

		// When
		sut?.navigateToBirthdayEntry()

		// Then
		XCTAssertTrue(viewControllerSpy.presentCalled, "Delegate method must be called")
		XCTAssertTrue(viewControllerSpy.thePresentedViewController is UINavigationController, "Type should match")
		XCTAssertTrue((viewControllerSpy.thePresentedViewController as? UINavigationController)?
						.viewControllers.first is BirthdateEntryViewController, "Type should match")
	}

	func testNavigateToBirthdayConfirmation() {

		// Given
		sut?.navigationController = navigationSpy
		let date = Date()

		// When
		sut?.navigateToBirthdayConfirmation(date)

		// Then
		XCTAssertEqual(navigationSpy.pushViewControllerCallCount, 1, "One viewcontroller should be presented")
	}

	func testNavigateBackToBirthdayEntry() {

		// Given
		sut?.navigationController = navigationSpy

		// When
		sut?.navigateBackToBirthdayEntry()

		// Then
		XCTAssertTrue(navigationSpy.popToRootViewControllerCalled, "Method should be called")

	}

	func testBirthdateConfirmeed() {

		// Given

		// When
		sut?.birthdateConfirmed()

		// Then
		XCTAssertTrue(viewControllerSpy.dismissCalled, "Delegate method must be called")
		XCTAssertTrue(birthdateSceneDelegateSpy.birthdateConfirmedCalled, "Delegate method must be called")
	}
}
