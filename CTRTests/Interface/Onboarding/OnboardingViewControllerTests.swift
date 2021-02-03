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
		image: .onboarding1,
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
				onboardingInfo: page,
				numberOfPages: 1
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
		XCTAssertEqual(strongSut.sceneView.title, page.title, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, page.message, "Message should match")
		XCTAssertEqual(strongSut.sceneView.image, page.image, "Image should match")
		XCTAssertEqual(strongSut.sceneView.primaryButton.titleLabel?.text, .next, "Button title should match")
	}

	func testNext() {

		// Given
		loadView()

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(coordinatorSpy.nextButtonClickedCalled, "Method should be called")
		XCTAssertEqual(coordinatorSpy.step, OnboardingStep.safelyOnTheRoad, "Step should match")
	}
}
