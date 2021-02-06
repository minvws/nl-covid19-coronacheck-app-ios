/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OnboardingViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: OnboardingViewController?

	var coordinatorSpy = OnboardingCoordinatorSpy()

	let page = OnboardingPage(
		title: "Onboarding Title",
		message: "Onboarding Message",
		image: .onboardingSafely,
		step: .safelyOnTheRoad,
		underlinedText: nil
	)

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()

		sut = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: coordinatorSpy,
				pages: [page]
			)
		)
		window = UIWindow()
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

	// MARK: Test

	/// Test all the content
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		guard let strongSut = sut else {

			XCTFail("Can not unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.sceneView.primaryButton.titleLabel?.text, .next, "Button title should match")
	}

	/// Test tap on the next button with only one item
	func testNextTappedWithOneItem() {

		// Given
		loadView()

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(coordinatorSpy.finishOnboardingCalled, "Method should be called")
	}

	/// Test tap on the next button with two items
	func testNextTappedWithTwoItems() {

		// Given
		sut = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: coordinatorSpy,
				pages: [page, page]
			)
		)
		loadView()

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertFalse(coordinatorSpy.finishOnboardingCalled, "Method should NOT be called")
	}

	/// Test tap on the next button with two items while on the second page
	func testWithTwoItemsWhileOnSecondPage() {

		// Given
		sut = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: coordinatorSpy,
				pages: [page, page]
			)
		)
		loadView()

		// When
		sut?.currentIndex = 1

		// Then
		XCTAssertNotNil(sut?.navigationItem.leftBarButtonItem, "There should be a back button")
	}

	/// Test tap on the next button with two items while on the second page
	func testNextTappedWithTwoItemsWhileOnSecondPage() {

		// Given
		sut = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: coordinatorSpy,
				pages: [page, page]
			)
		)
		loadView()
		sut?.currentIndex = 1

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(coordinatorSpy.finishOnboardingCalled, "Method should be called")
	}

	/// Test tap on the next button with two items while on the second page
	func testBackButtonTappedWithTwoItemsWhileOnSecondPage() {

		// Given
		sut = OnboardingViewController(
			viewModel: OnboardingViewModel(
				coordinator: coordinatorSpy,
				pages: [page, page]
			)
		)
		loadView()
		sut?.currentIndex = 1

		// When
		sut?.backbuttonTapped()

		// Then
		XCTAssertFalse(coordinatorSpy.finishOnboardingCalled, "Method should not be called")
		XCTAssertEqual(sut?.currentIndex, 0, "Current Index should be 0")
	}
}
