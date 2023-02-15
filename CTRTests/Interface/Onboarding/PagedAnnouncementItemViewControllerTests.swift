/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Shared
@testable import Resources
@testable import Models

class PagedAnnouncementItemViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: PagedAnnouncementItemViewController?

	var coordinatorSpy = OnboardingCoordinatorSpy()

	let page = PagedAnnoucementItem(
		title: "Onboarding Title",
		content: "Onboarding Message",
		image: I.onboarding.safely(),
		imageBackgroundColor: C.white(),
		step: 1
	)

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()
		sut = PagedAnnouncementItemViewController(
			viewModel: PagedAnnouncementItemViewModel(
				item: page
			),
			shouldShowWithFullWidthHeaderImage: false
		)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		if let sut {
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
		XCTAssertEqual(strongSut.sceneView.content, page.content, "Message should match")
		XCTAssertEqual(strongSut.sceneView.image, page.image, "Image should match")
	}
}
