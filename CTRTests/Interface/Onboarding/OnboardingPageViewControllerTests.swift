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
	var consentDelegateSpy = ConsentDelegateSpy()

	let page = OnboardingPage(
		title: "Onboarding Title",
		message: "Onboarding Message",
		image: .onboardingSafely,
		step: .safelyOnTheRoad,
		underlinedText: "Message",
		consent: nil
	)

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()
		consentDelegateSpy = ConsentDelegateSpy()

		sut = OnboardingPageViewController(
			viewModel: OnboardingPageViewModel(
				coordinator: coordinatorSpy,
				consentDelegate: consentDelegateSpy,
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

	// MARK: TestDoubles

	class ConsentDelegateSpy: ConsentDelegate {

		var consentGivenCalled = false

		func consentGiven(_ consent: Bool) {

			consentGivenCalled = true
		}
	}

	// MARK: Test

	/// Test all the content without consent
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
		XCTAssertFalse(consentDelegateSpy.consentGivenCalled, "Method should not be called")
	}

	/// Test all the content with consent
	func testContentWithConsent() {

		// Given
		sut = OnboardingPageViewController(
			viewModel: OnboardingPageViewModel(
				coordinator: coordinatorSpy,
				consentDelegate: consentDelegateSpy,
				onboardingInfo: OnboardingPage(
					title: "Onboarding Title",
					message: "Onboarding Message",
					image: .onboardingSafely,
					step: .safelyOnTheRoad,
					underlinedText: "Message",
					consent: "consent"
				)
			)
		)

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
		XCTAssertTrue(consentDelegateSpy.consentGivenCalled, "Method should be called")
	}

	/// Test the user tapped on the link
	func testLink() {

		// Given
		loadView()

		// When
		sut?.linkTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.showPrivacyPageCalled, "Method should be called")
	}

	/// Test the user tapped on the consent button
	func testConsentGiven() {

		// Given
		loadView()

		// When
		sut?.sceneView.consentButton.sendActions(for: .valueChanged)

		// Then
		XCTAssertTrue(consentDelegateSpy.consentGivenCalled, "Method should be called")
	}
}
