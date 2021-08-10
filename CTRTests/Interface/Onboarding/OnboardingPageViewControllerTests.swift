/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OnboardingPageViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: OnboardingPageViewController?

	var coordinatorSpy = OnboardingCoordinatorSpy()

	let page = OnboardingPage(
		title: "Onboarding Title",
		message: "Onboarding Message",
		image: I.onboarding.safely(),
		step: .safelyOnTheRoad
	)

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()
		sut = OnboardingPageViewController(
			viewModel: OnboardingPageViewModel(
				coordinator: coordinatorSpy,
				onboardingInfo: page
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

	/// Test all the content without consent
	func testContent() throws {

		// Given

		// When
		loadView()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.sceneView.title, page.title, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, page.message, "Message should match")
		XCTAssertEqual(strongSut.sceneView.image, page.image, "Image should match")
	}
}
